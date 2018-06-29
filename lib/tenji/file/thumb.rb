module Tenji
  module File
    class Thumb < Jekyll::StaticFile
      using Tenji::Refinements

      def destination(dest)
        dest.is_a! String

        input_path = Tenji::Config.dir(:thumbs)
        output_path = Tenji::Config.dir(:thumbs, output: true)

        path = super dest
        path.sub input_path, output_path
      end
    end
  end
end
