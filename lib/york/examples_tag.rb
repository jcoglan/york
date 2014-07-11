module York
  class ExamplesTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @example_name = York.parse_tag_params(text, 1).first
    end

    def render(context)
      context.registers[EXAMPLE_REGISTER] = @example_name
      ''
    end
  end

  Liquid::Template.register_tag('examples', ExamplesTag)
end
