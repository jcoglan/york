module York
  class Highlighter

    def initialize(pathname, language)
      @pathname = pathname
      @contents = File.read(pathname).strip
      @language = language.downcase
    end

    def lang
      Pygments::Lexer.find(@language).name.downcase
    rescue
      @language
    end

    def render(options)
      markup = Pygments.highlight(@contents, :lexer => @language, :options => {
        :encoding => 'utf-8',
        :linenos  => options['linenos'] ? 'table' : false
      })

      from = options.fetch('from') { 1 } - 1
      to   = options.fetch('to') { @contents.lines.size } - 1
      doc  = Nokogiri::HTML.fragment(markup)

      doc.css('pre').each do |pre|
        code = Nokogiri::XML::Node.new('code', doc)
        code['class'] = "language-#{lang}"
        code['data-lang'] = lang

        code.inner_html = pre.inner_html.lines[from..to].join('')
        pre.children = code
      end

      doc.to_html
    end

  end
end
