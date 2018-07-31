# frozen_string_literal: true

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

        base_file = (output_dir + thumb.name).expand_path
        factors = 1..Tenji::Config.option('scale_max')

        factors.each do |f|
          suffix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
          output_file = base_file.append_to_base suffix
          dimensions = thumb.dimensions.transform_values { |v| v.nil? ? v : v * f }
          write_file source_file, output_file, dimensions, thumb.resize
        end
      end

      private_class_method def self.write_file(input, output, dimensions, resize)
        return if output.exist? && (output.mtime > input.mtime)
        
        image = Magick::ImageList.new input.realpath.to_s
        image.auto_orient!
        
        case resize
        when 'fill'
          image.resize_to_fill! dimensions['x'], dimensions['y']
        when 'fit'
          image.resize_to_fit! dimensions['x'], dimensions['y']
        end
        
        image.write output.to_s
        image.destroy!
      end
    end
  end
end
