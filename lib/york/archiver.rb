require 'fileutils'
require 'find'

module York
  class Archiver < Jekyll::Generator

    class Example < Jekyll::StaticFile
      def path
        York.source_dir(@site).join(@dir, @name).to_s
      end

      def destination(dest)
        York.target_dir(@site).join(@dir, @name).to_s
      end
    end

    class Null < Jekyll::StaticFile
      def write(dest)
      end
    end

    def generate(site)
      source_dir = York.source_dir(site)

      source_dir.children.each do |example|
        Find.find(example.to_s) do |path|
          next unless File.file?(path)

          pathname = Pathname.new(path)
          relative = pathname.relative_path_from(source_dir)

          file = Example.new(site, site.source, relative.parent.to_s, relative.basename.to_s)
          site.static_files << file
        end

        generate_archive(site, example, TAR_EXTENSION) do |source, archive|
          system 'tar', '-zcvf', archive.to_s, source.to_s
        end

        generate_archive(site, example, ZIP_EXTENSION) do |source, archive|
          system 'zip', archive.to_s, source.to_s, '-r'
        end
      end
    end

    def generate_archive(site, source, ext)
      basename = source.basename
      archive  = York.path_to_archive(site, basename, ext)
      relative = archive.relative_path_from(Pathname.new(site.dest))

      FileUtils.mkdir_p(archive.parent)
      FileUtils.rm_rf(archive)
      FileUtils.cd(source.parent) { yield basename, archive }

      file = Null.new(site, site.source, relative.parent.to_s, relative.basename.to_s)
      site.static_files << file
    end

  end
end
