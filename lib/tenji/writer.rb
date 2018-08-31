# frozen_string_literal: true

module Tenji
  class Writer
    using Tenji::Refinements

    def write_thumb(input_path, output_path, constraints, resize)
      return if File.exist?(output_path) && File.mtime(output_path) > File.mtime(input_path)
      
      image = resized_image input_path, constraints, resize
      image.write output_path
      image.destroy!
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
