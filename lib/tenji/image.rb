module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :metadata, :name, :text, :thumbs

    DEFAULTS = { 'layout' => 'gallery_image',
                 'title' => 'Image' }

    def initialize(file, sizes, options = {})
      file.is_a! Pathname
      file.exist!
      sizes.is_a! Hash
      options.is_a! Hash

      @name = file.basename.to_s
      @thumbs = init_thumbs file.basename, sizes.keys

      co_file = file.sub_ext Tenji::Config.ext(:page)
      fm, text = Tenji::Utilities.read_yaml co_file
      @metadata = init_metadata fm, options
      @text = text
    end

    private def init_metadata(frontmatter, options)
      frontmatter.is_a! Hash
      options.is_a! Hash
      DEFAULTS.merge(options).merge(options)
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
      Tenji::Thumb.new sizes 
    end
  end
end
