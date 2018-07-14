# frozen_string_literal: true

module Tenji
  module File
    class Image < Jekyll::StaticFile
      using Tenji::Refinements

      def initialize(image, *args)
        image.is_a! Tenji::Image
        @image = image
        super *args
      end

      def destination(dest)
        dest.is_a! String

        input_path = Tenji::Config.dir(:galleries)
        output_path = Tenji::Config.dir(:galleries, output: true)

        path = super dest
        path.sub input_path, output_path
      end
    end
  end
end
