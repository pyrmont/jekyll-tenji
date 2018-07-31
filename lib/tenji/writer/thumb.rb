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
          constraints = thumb.constraints.transform_values { |v| v.nil? ? v : v * f }
          write_file source_file, output_file, constraints, thumb.resize_function
        end
      end

      private_class_method def self.resize(image, constraints, resize_function)
        case resize_function
        when 'fill'
          msg = 'The fill resize function requires both constraints'
          raise Tenji::ResizeError, msg unless constraints['x'] && constraints['y']
          image.resize_to_fill! constraints['x'], constraints['y']
        when 'fit'
          msg = 'The fit resize function requires at least one dimension'
          raise Tenji::ResizeError, msg unless constraints['x'] || constraints['y']
          image.resize_to_fit! constraints['x'], constraints['y']
        else
          msg = 'Unrecognised resize function'
          raise StandardError, msg
        end
      end

      private_class_method def self.write_file(input, output, constraints, resize_function)
        return if output.exist? && (output.mtime > input.mtime)

        image = Magick::Image.read(input.realpath.to_s).first
        image.auto_orient!
        resize image, constraints, resize_function
        image.write output.to_s
        image.destroy!
      end
    end
  end
end
