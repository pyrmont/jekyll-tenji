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
                'next' => next_pos,
                'prev' => prev_pos }
      @metadata.merge attrs
    end

    def to_liquid()
      attrs = { 'content' => @text }
      @metadata.merge(image).merge(attrs)
    end

    private def image()
      attrs = { 'name' => @name,
                'position' => @position,
                'link' => link,
                'page_link' => page_link,
                'x' => @exif['width'],
                'y' => @exif['height'] }
      attrs.merge @thumbs
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

    private def link()
      galleries = Tenji::Config.dir 'galleries', output: true
      album = @gallery.dirname
      "/#{galleries}/#{album}/#{@name}"
    end

    private def next_pos()
      if @position.nil?
        nil
      elsif @position + 1 == @gallery.images.length
        nil
      else
        @position + 1
      end
    end

    private def page_link()
      galleries = Tenji::Config.dir 'galleries', output: true
      album = @gallery.dirname
      name = @name.sub_ext(Tenji::Config.ext('page', output: true))
      "/#{galleries}/#{album}/#{name}"
    end

    private def prev_pos()
      if @position.nil?
        nil
      elsif @position == 0
        nil
      else
        @position - 1
      end
    end

    private def title_from_name()
      @name.sub /^\d+-/, ''
    end
  end
end
