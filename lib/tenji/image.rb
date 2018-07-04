module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :exif, :gallery, :metadata, :name, :quality, :text, :thumbs

    DEFAULTS = { 'layout' => 'gallery_image', 'quality' => 'original' }

    def initialize(file, sizes, quality, gallery)
      file.is_a! Pathname
      sizes.is_a! Hash
      quality.is_a! String
      gallery.is_a! Tenji::Gallery

      file.exist!
      file.file!

      @global = Tenji::Config.settings('image') || Hash.new

      co_file = file.sub_ext Tenji::Config.ext(:page)
      fm, text = Tenji::Utilities.read_yaml co_file

      @name = file.basename.to_s
      @quality = quality
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

    def input_name()
      return @name if @metadata['quality'] == 'original'
      Pathname.new(@name).append_to_base("-#{@metadata['quality']}").to_s
    end

    def to_liquid()
      attrs = { 'name' => name,
                'content' => text,
                'exif' => exif,
                'thumbs' => thumbs }
      @metadata.merge attrs
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
      attrs = { 'exif' => @exif, 
                'gallery' => @gallery, 
                'quality' => @quality,
                'title' => title_from_name }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end

    private def init_thumbs(sizes)
      sizes.is_a! Hash

      sizes.keys.reduce(Hash.new) do |memo,s|
        memo.update({ s => Tenji::Thumb.new(s, sizes[s], self) })
      end
    end

    private def title_from_name()
      @name.sub /^\d+-/, ''
    end
  end
end
