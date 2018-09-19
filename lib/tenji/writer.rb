# frozen_string_literal: true

module Tenji

  # A file writer
  #
  # {Tenji::Writer} provides a mechanism for Tenji to write files to disk.
  # At the time of writing, the only such files are thumbnail images.
  #
  # @since 0.1.0
  # @api private
  class Writer
    using Tenji::Refinements

    # Write a thumbnail to disk
    #
    # This method begins by checking whether there is already a thumbnail on
    # disk that was more recently modified than the source file. If it was, this
    # is taken to mean that the thumbnail is newer and does not need to be
    # generated or written.
    #
    # In all other cases, ImageMagick is used to generate a thumbnail and then
    # write that to disk. The object created by ImageMagick is immediately
    # destroyed after writing to conserve memory.
    #
    # It should be noted that the `constraints` parameter is a hash that holds
    # the height and width constraints expressed as 
    # `{ 'x' => max_x, 'y' => max_y }`. Depending on the resizing function, one
    # or both constraints need to be set to an integer (`fill` requires both
    # constraints, `fit` requires at least one).
    #
    # @param input_path [String] the path to the source image
    # @param output_path [String] the path to where the output will be written
    # @param constraints [Hash] height and width constraints
    # @param resize ['fill', 'fit'] the name of the resizing function to use
    #
    # @since 0.1.0
    # @api private
    def write_thumb(input_path, output_path, constraints, resize)
      return if File.exist?(output_path) && File.mtime(output_path) > File.mtime(input_path)
              
      Tenji::Path.new(output_path).parent.mkpath
      
      image = resized_image input_path, constraints, resize
      image.write output_path
      image.destroy!
    end

    # Create a resized image
    #
    # @param path [String] the path to the source image
    # @param constraints [Hash] height and width constraints
    # @param resize ['fill', 'fit'] the name of the resizing function
    #
    # @raise [Tenji::Writer::ResizeConstraintError] if `constraints` were not 
    #   valid
    # @raise [Tenji::Writer::ResizeInvalidFunctionError] if `resize` is not
    #   `'fill'` or `'fit'`
    #
    # @return [Magick::Image] the resized image
    #
    # @since 0.1.0
    # @api private
    private def resized_image(path, constraints, resize)
      image = Magick::Image.read(path).first
      image.auto_orient!

      case resize
      when 'fill'
        raise ResizeConstraintError unless constraints['x'] && constraints['y']
        image.resize_to_fill! constraints['x'], constraints['y']
      when 'fit'
        raise ResizeConstraintError unless constraints['x'] || constraints['y']
        image.resize_to_fit! constraints['x'], constraints['y']
      else
        raise ResizeInvalidFunctionError
      end
    end
  end
end
