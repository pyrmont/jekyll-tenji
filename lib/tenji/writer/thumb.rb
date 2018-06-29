module Tenji
  module Writer
    class Thumb
      using Tenji::Refinements

      def self.write(thumb, source_file, output_dir)
        thumb.is_a! Tenji::Thumb
        source_file.is_a! Pathname
        output_dir.is_a! Pathname

        source_file.exist!
        output_dir.exist!

        output_file = (output_dir + thumb.name).expand_path
        return if output_file.exist? && (output_file.mtime > source_file.mtime)
        write_file source_file, output_file, thumb.dimensions
      end

      private_class_method def self.write_file(input, output, dimensions)
        image = Magick::ImageList.new input.realpath.to_s
        image.auto_orient!
        image.resize_to_fit! dimensions['x'], dimensions['y']
        image.write output.to_s
      end
    end
  end
end
