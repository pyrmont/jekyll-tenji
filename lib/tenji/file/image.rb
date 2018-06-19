module Tenji
  module File
    class Image < Jekyll::StaticFile
      using Tenji::Refinements

      def destination(dest)
        dest.is_a! String

        input = Tenji::Config.dir(:galleries)
        output = Tenji::Config.dir(:galleries, output: true)
        rel_dir = (destination_rel_dir).sub(input, output)
        @site.in_dest_dir(*[dest, rel_dir, @name].compact)
      end
    end
  end
end
