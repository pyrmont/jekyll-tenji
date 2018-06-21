module Tenji
  module Writer
    class Thumb
      using Tenji::Refinements

      def self.write(thumbs, source_file, output_dir, sizes)
        thumbs.is_a! Tenji::Thumb
        source_file.is_a! Pathname
        output_dir.is_a! Pathname
        sizes.is_a! Hash

        source_file.exist!
        output_dir.exist!

        input_name = source_file.basename.sub_ext('').to_s
        sizes.each do |name,size|
          output_basename = "#{input_name}-#{name}.jpg"
          output_file = (output_dir + output_basename).expand_path
          if output_file.exist? && (output_file.mtime > source_file.mtime)
            next
          else
            write_file source_file, output_file, size
          end
        end
      end

      private_class_method def self.write_file(input, output, size)
        image = Magick::ImageList.new input.realpath.to_s
        image.auto_orient!
        image.resize_to_fit! size['x'], size['y']
        image.write output.to_s
      end
    end
  end
end
