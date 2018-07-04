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

      def path
        unless @image.gallery.metadata['quality'] == 'original'
          galleries_dir = Tenji::Config.dir 'galleries'
          thumbs_dir = Tenji::Config.dir 'thumbs'
          super().sub(galleries_dir, thumbs_dir).sub(@name, @image.input_name)
        else
          super
        end
      end
    end
  end
end
