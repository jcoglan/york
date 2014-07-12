module York

  class ArchiveUrlTag < Liquid::Tag
    def render(context)
      example   = context.registers[EXAMPLE_REGISTER] || ''
      site      = context.registers[:site]
      site_dest = Pathname.new(site.dest)
      pathname  = York.path_to_archive(site, example, extension)

      '/' + pathname.relative_path_from(site_dest).to_s
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
