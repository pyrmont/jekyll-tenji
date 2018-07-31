# frozen_string_literal: true

module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :dimensions, :name, :resize, :size, :source

    def initialize(size, dimensions, resize, source)
      size.is_a! String
      dimensions.is_a! Hash
      resize.is_a! String
      source.is_a! Tenji::Image

      @name = source.name.append_to_base "-#{size}"
      @size = size
      @dimensions = dimensions
      @resize = init_resize resize
      @source = source
    end

    def to_liquid()
      { 'name' => @name,
        'url' => url,
        'size' => @size,
        'source' => @source }
    end

    private def init_resize(type_of_resize)
      case type_of_resize.downcase
      when 'fill'
        return 'fill'
        msg = "Thumbnail resize type 'fill' requires both dimensions"
        raise StandardError, msg
      when 'fit'
        return 'fit' if @dimensions['x'] && @dimensions['y']
      else
        msg = "Thumbnail resize type must be 'fill' or 'fit'" 
        raise StandardError, msg
      end
    end

    private def url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @source.gallery.dirnames['output']
      thumbs = Tenji::Config.dir 'thumbs', output: true
      "/#{galleries}/#{gallery}/#{thumbs}/#{@name}"
    end
  end
end
