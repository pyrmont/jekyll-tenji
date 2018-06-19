module Tenji
  module File
    class Thumb < Jekyll::StaticFile
      using Tenji::Refinements

      def destination(dest)
        dest.is_a! String

        input = Tenji::Config.dir(:thumbs)
        output = Tenji::Config.dir(:thumbs, output: true)
        rel_dir = (destination_rel_dir).gsub(input, output)
        @site.in_dest_dir(*[dest, rel_dir, @name].compact)
      end
    end
  end
end
