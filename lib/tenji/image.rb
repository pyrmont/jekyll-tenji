module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :exif, :gallery, :metadata, :name, :text, :thumbs

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

      @text = text
      @metadata = init_metadata fm
    end

    def <=>(other)
      other.is_a! Tenji::Image
      @name <=> other.name
    end

    def data()
      attrs = { 'image' => image,
                'next' => @gallery.next_image(self),
                'prev' => @gallery.prev_image(self) }
      @metadata.merge attrs
    end

    def image()
      attrs = { 'name' => @name,
                'link' => link,
                'x' => @exif['width'],
                'y' => @exif['height'] }
      attrs.merge @thumbs
    end

    def input_name()
      quality = @gallery.metadata['quality']
      if quality == 'original'
        @name
      else
        Pathname.new(@name).append_to_base("-#{quality}").to_s
      end
    end

    def to_liquid()
      attrs = { 'content' => @text }
      @metadata.merge(image).merge(attrs)
    end

    private def init_exif(file)
      file.is_a! Pathname
      path = file.realpath.to_s
      begin
        data = EXIFR::JPEG.new(::File.open(path)).to_hash
        data.transform_keys &:to_s
      rescue EXIFR::MalformedJPEG => e
        Jekyll.logger.warn "EXIFR Exception reading #{path}: #{e.message}"
        Hash.new
      end
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

    private def title_from_name()
      @name.sub /^\d+-/, ''
    end
  end
end
