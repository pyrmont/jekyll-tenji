module Tenji
  module File
    class Image < Jekyll::StaticFile
      def destination(dest)
        input = Tenji::Config.dir(:galleries)
        output = Tenji::Config.dir(:galleries, output: true)
        rel_dir = (destination_rel_dir).gsub(input, output)
        @site.in_dest_dir(*[dest, rel_dir, @name].compact)
      end
    end
  end
end
