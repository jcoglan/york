module York

  class ArchiveUrlTag < Liquid::Tag
    def render(context)
      example_name = context.registers[EXAMPLE_REGISTER] || ''
      site         = context.registers[:site]
      site_dest    = Pathname.new(site.dest)
      full_path    = York.target_dir(site).join(example_name, example_name + extension)

      '/' + full_path.relative_path_from(site_dest).to_s
    end
  end

  class TarArchiveUrlTag < ArchiveUrlTag
    def extension
      TAR_EXTENSION
    end
  end

  Liquid::Template.register_tag('tar_archive_url', TarArchiveUrlTag)

  class ZipArchiveUrlTag < ArchiveUrlTag
    def extension
      ZIP_EXTENSION
    end
  end

  Liquid::Template.register_tag('zip_archive_url', ZipArchiveUrlTag)

end
