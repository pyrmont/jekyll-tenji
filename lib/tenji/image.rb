module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :gallery, :metadata, :name, :text, :thumbs

    DEFAULTS = { 'layout' => 'gallery_image',
                 'title' => 'Image' }

    def initialize(file, sizes, gallery)
      file.is_a! Pathname
      file.exist!
      sizes.is_a! Hash
      gallery.is_a! Tenji::Gallery

      @gallery = gallery
      @name = file.basename.to_s
      @thumbs = init_thumbs file.basename, sizes.keys

      co_file = file.sub_ext Tenji::Config.ext(:page)
      fm, text = Tenji::Utilities.read_yaml co_file
      @metadata = init_metadata fm
      @text = text
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash

      global = Tenji::Config.settings('image') || Hash.new
      attributes = { 'gallery' => @gallery, 'thumbs' => @thumbs }
      DEFAULTS.merge(attributes).merge(global).merge(frontmatter)
    end

    private def init_thumbs(filename, keys)
      filename.is_a! Pathname
      keys.is_a! Array

      name = filename.sub_ext('')
      ext = '.jpg'
      sizes = Hash.new
      keys.each do |k|
        sizes[k] = name.to_s + '-' + k + ext
      end
      Tenji::Thumb.new sizes, self 
    end
  end
end
