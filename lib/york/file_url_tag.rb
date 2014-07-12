module York
  class FileUrlTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @filename = York.parse_tag_params(text, 1).first
    end

    def render(context)
      example   = context.registers[EXAMPLE_REGISTER] || ''
      site      = context.registers[:site]
      site_dest = Pathname.new(site.dest)
      pathname  = York.target_dir(site).join(example, @filename)

      '/' + pathname.relative_path_from(site_dest).to_s
    end
  end

  Liquid::Template.register_tag('file_url', FileUrlTag)
end
