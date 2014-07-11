module York
  class ExamplesTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @example_name = text.strip
    end

    def render(context)
      context.registers[EXAMPLE_REGISTER] = @example_name
      ''
    end
  end

  Liquid::Template.register_tag('examples', ExamplesTag)
end
