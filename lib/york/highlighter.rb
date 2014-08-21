module York
  class Highlighter

    DIFF_OPTIONS = ['compare', 'diff']

    TAGS = { '+' => 'ins', '-' => 'del', nil => 'span' }

    TABLE = <<-HTML
<table class="highlightable">
  <tr>
    <td class="linenos">
      <div class="linenodiv"><pre></pre></div>
    </td>
    <td class="linenos">
      <div class="linenodiv"><pre></pre></div>
    </td>
    <td class="code"></td>
  </tr>
</table>
    HTML

    def initialize(pathname, language)
      @pathname = pathname
      @language = language.downcase
    end

    def render(options)
      return render_diff(options) if DIFF_OPTIONS.any?(&options.method(:has_key?))
      contents = read_file(options)

      markup = Pygments.highlight(contents, :lexer => @language, :options => {
        :encoding => 'utf-8',
        :linenos  => options['linenos'] ? 'table' : false
      })

      doc = Nokogiri::HTML.fragment(markup)
      filter_lines(doc, options, contents)
    end

    def render_diff(options)
      contents = read_diff(options)
      file     = Git::Diff.parse(contents).files.first
      html     = %Q{<div class="highlight"><pre></pre></div>}
      doc      = Nokogiri::HTML.fragment(html)
      pre      = doc.css('pre').first
      lines    = [[], []]

      file.each_hunk do |hunk|
        line = Nokogiri::XML::Node.new('span', doc)
        line['class'] = 'header'
        line['style'] = 'display: block'
        line.children = Nokogiri::XML::Text.new(hunk.header + "\n", doc)
        pre << line

        lines.each { |l| l << [nil, nil] }

        hunk.each_line do |line|
          text   = line.text.gsub(/^$/, ' ')
          markup = Pygments.highlight(text, :lexer => @language, :options => {:encoding => 'utf-8'})
          span   = Nokogiri::XML::Node.new(TAGS[line.type], doc)

          span['style'] = 'display: block'
          span.children = Nokogiri::HTML.fragment(markup).css('pre').children
          pre << span

          pairs = [[line.type, line.a_line], [line.type, line.b_line]]
          lines.zip(pairs).each { |list, n| list << n }
        end
      end

      doc = diff_linenos(doc, lines) if options['linenos']
      filter_lines(doc, options, contents)
    end

  private

    def diff_linenos(doc, lines)
      table = Nokogiri::HTML.fragment(TABLE)

      table.css('pre').each_with_index do |pre, i|
        lines[i].each_with_index do |(type, n), j|
          span = Nokogiri::XML::Node.new(TAGS[type], table)
          span['style'] = 'display: block'
          span.children = Nokogiri::XML::Text.new("#{n || ' '}\n", table)

          pre << span
        end
      end
      table.css('.code').first << doc
      table
    end

    def filter_lines(document, options, contents)
      from = options.fetch('from') { 1 } - 1
      to   = options.fetch('to') { contents.lines.size } - 1

      document.css('pre').each do |pre|
        code = Nokogiri::XML::Node.new('code', document)
        code['class'] = "language-#{lang}"
        code['data-lang'] = lang

        code.inner_html = pre.inner_html.lines[from..to].join('')
        pre.children = code
      end

      document.to_html.gsub(/>\s*(<tr>)/i, ">\n\\1").gsub(/(<\/tr>)\s*</i, "\\1\n<")
    end

    def read_file(options)
      return File.read(@pathname).strip unless at = options['at']

      FileUtils.cd(@pathname.parent) do
        file = Shellwords.escape([at, @pathname.basename].join(':./'))
        return `git show #{file}`
      end
    end

    def read_diff(options)
      if ref = options['compare']
        before, after = *ref.split('...')
      elsif ref = options['diff']
        before, after = nil, ref
      end

      contents = nil
      before   = before && Shellwords.escape(before)
      after    = after && Shellwords.escape(after)
      basename = Shellwords.escape(@pathname.basename)

      FileUtils.cd(@pathname.parent) { contents = `git diff #{before} #{after} #{basename}` }
      contents
    end

    def lang
      Pygments::Lexer.find(@language).name.downcase
    rescue
      @language
    end

    def `(command)
      result = super
      unless $?.exitstatus.zero?
        raise ArgumentError, "Command failed: `#{command}`"
      end
      result
    end

  end
end
