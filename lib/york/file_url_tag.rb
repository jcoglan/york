module York
  class FileUrlTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @filename = York.parse_tag_params(text, 1).first
    end

    def render(context)
      example_name = context.registers[EXAMPLE_REGISTER] || ''
      site         = context.registers[:site]
      site_dest    = Pathname.new(site.dest)
      full_path    = York.target_dir(site).join(example_name, @filename)

      '/' + full_path.relative_path_from(site_dest).to_s
    end
  end

  Liquid::Template.register_tag('file_url', FileUrlTag)
end
