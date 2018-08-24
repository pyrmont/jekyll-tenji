# frozen_string_literal: true

module Tenji
  class Writer
    using Tenji::Refinements

    def write_thumb(input_path, base_path, constraints, resize, factors = 1..1)
      factors.each do |f|
        output_path = f == 1 ? base_path : base_path.append_to_base("-#{f}x")

        next if File.exist?(output_path) && File.mtime(output_path) > File.mtime(input_path)
        
        scaled_constraints = constraints.transform_values { |v| v * f }
        image = resized_image input_path, scaled_constraints, resize
        image.write output_path
        image.destroy!
      end
    end

    private def resized_image(path, constraints, resize)
      image = Magick::Image.read(path).first
      image.auto_orient!

      case resize
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
  end
end
