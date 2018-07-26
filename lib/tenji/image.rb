# frozen_string_literal: true

module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :exif, :gallery, :metadata, :name, :text, :thumbs
    attr_accessor :position

    DEFAULTS = { 'layout' => 'gallery_image' }

    def initialize(file, sizes, gallery)
      file.is_a! Pathname
      sizes.is_a! Hash
      gallery.is_a! Tenji::Gallery

      file.exist!
      file.file!

      @global = Tenji::Config.settings('image') || Hash.new

      co_file = file.sub_ext Tenji::Config.ext(:page)
      fm, text = Tenji::Utilities.read_yaml co_file

      @name = file.basename.to_s
      @gallery = gallery
      @exif = init_exif file
      @thumbs = init_thumbs sizes
      @position = nil

      @text = text
      @metadata = init_metadata fm
    end

    def <=>(other)
      other.is_a! Tenji::Image
      @name <=> other.name
    end

    def data()
      attrs = { 'image' => image,
                'next' => image_next,
                'prev' => image_prev }
      @metadata.merge attrs
    end

    def to_liquid()
      attrs = { 'content' => @text }
      @metadata.merge(image).merge(attrs)
    end

    private def image()
      attrs = { 'name' => @name,
                'position' => @position,
                'url' => url,
                'page_url' => page_url,
                'x' => @exif['width'],
                'y' => @exif['height'] }
      attrs.merge @thumbs
    end

    private def image_next()
      return nil if @position.nil?
      return nil if @position + 1 == @gallery.images.length
      
      @gallery.images[@position + 1]
    end

    private def image_prev()
      return nil if @position.nil?
      return nil if @position == 0
      
      @gallery.images[@position - 1]
    end

    private def init_exif(file)
      file.is_a! Pathname
      data = Tenji::Utilities.read_exif file
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      attrs = { 'title' => title_from_name,
                'gallery' => @gallery,
                'exif' => @exif }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end

    private def init_thumbs(sizes)
      sizes.is_a! Hash
      sizes.keys.reduce(Hash.new) do |memo,s|
        memo.update({ s => Tenji::Thumb.new(s, sizes[s], self) })
      end
    end

    private def page_url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @gallery.dirnames['output']
      name = @name.sub_ext(Tenji::Config.ext('page', output: true))
      "/#{galleries}/#{gallery}/#{name}"
    end

    private def title_from_name()
      @name.sub /^\d+-/, ''
    end
    
    private def url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @gallery.dirnames['output']
      "/#{galleries}/#{gallery}/#{@name}"
    end

  end
end
