module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :dimensions, :name, :size, :source

    def initialize(size, dimensions, source)
      size.is_a! String
      dimensions.is_a! Hash
      source.is_a! Tenji::Image

      @name = Pathname.new(source.name).append_to_base("-#{size}").to_s
      @size = size
      @dimensions = dimensions
      @source = source
    end

    def to_liquid()
      { 'name' => @name,
        'link' => link,
        'x' => @dimensions['x'],
        'y' => @dimensions['y'],
        'size' => @size,
        'source' => @source }
    end

    private def link()
      galleries = Tenji::Config.dir 'galleries', output: true
      thumbs = Tenji::Config.dir 'thumbs', output: true
      album = @source.gallery.dirname
      "/#{galleries}/#{album}/#{thumbs}/#{@name}"
    end

  end
end
