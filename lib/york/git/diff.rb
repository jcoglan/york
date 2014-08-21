require 'pathname'

module Git
  class Diff < Struct.new(:files)

    LINE = /\n([ \-\+])(.*)/
    HUNK = /\n(@@ -(\d+),(\d+) \+(\d+),(\d+) @@(.*))((#{LINE.source})+)/
    FILE = /^(diff .+)\n(index .+)\n(--- (.+))\n(\+\+\+ (.+))((#{HUNK.source})+)/ 

    DEV_NULL = '/dev/null'

    class File < Struct.new(:diff_line, :index_line, :a_path, :b_path, :hunks)
      def each_hunk
        hunks.each { |h| yield h }
      end

      def pathname
        path = [a_path, b_path].find { |p| p != DEV_NULL }
        Pathname.new(path.gsub(/^(a|b)\//, ''))
      end
    end

    class Hunk < Struct.new(:header, :a_line, :a_size, :b_line, :b_size, :context, :lines)
      def each_line
        lines.each { |l| yield l }
      end
    end

    Line = Struct.new(:type, :a_line, :b_line, :text)

    def self.parse(diff)
      files = diff.scan(FILE).map do |diff, index, del, a_path, ins, b_path, hunks|
        hunks = hunks.scan(HUNK).map do |header, *match|
          a_lineno, a_size, b_lineno, b_size = linenos = match[0..3].map(&:to_i)
          context = match[4]

          lines = match[5].scan(LINE).map do |sigil, text|
            type = (sigil == ' ') ? nil : sigil

            a_line = (type == '+') ? nil : a_lineno
            a_lineno += 1 if a_line

            b_line = (type == '-') ? nil : b_lineno
            b_lineno += 1 if b_line

            Line.new(type, a_line, b_line, text)
          end
          Hunk.new(header, *linenos, context, lines)
        end
        File.new(diff, index, a_path, b_path, hunks)
      end
      Diff.new(files)
    end

    def each_file
      files.each { |f| yield f }
    end

  end
end
