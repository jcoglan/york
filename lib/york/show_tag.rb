module York
  class ShowTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @filename, @options = *York.parse_tag_params(text, 1)
    end

    def render(context)
      site     = context.registers[:site]
      example  = context.registers[EXAMPLE_REGISTER] || ''
      pathname = York.source_dir(site).join(example, @filename)
      language = @options.fetch('lang') { York.guess_language(pathname) }

      Highlighter.new(pathname, language).render(@options)
    end
  end

  Liquid::Template.register_tag('show', ShowTag)
end

