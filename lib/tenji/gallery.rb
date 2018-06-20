module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirname, :images, :metadata, :text

    def initialize(dir:)
      dir.is_a! Pathname
      dir.exist!

      @dirname = dir.basename.to_s

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm, dir
      @text = text

      @images = init_images dir
    end

    private def init_images(dir)
      dir.is_a! Pathname

      dir.images.map do |i|
        Tenji::Gallery::Image.new i, @metadata['sizes']
      end
    end

    private def init_metadata(frontmatter, dir)
      frontmatter.is_a! Hash
      dir.is_a! Pathname
      Tenji::Gallery::Metadata.new frontmatter, dir.basename.to_s
    end
  end
end
