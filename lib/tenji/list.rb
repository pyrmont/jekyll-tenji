module Tenji
  class List
    using Tenji::Refinements

    attr_reader :dirname, :galleries, :metadata, :text

    DEFAULTS = { 'title' => 'Photo Albums',
                 'layout' => 'gallery_list' }

    def initialize(dir)
      dir.is_a! Pathname
      dir.exist!

      @global = Tenji::Config.settings('list') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))

      @galleries = init_galleries dir
      @dirname = dir.basename.to_s
      @metadata = init_metadata fm
      @text = text
    end

    private def init_galleries(dir)
      dir.is_a! Pathname
      galleries = dir.subdirectories.map do |d|
                    Tenji::Gallery.new d, self
                  end
      galleries.sort
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      attrs = { 'galleries' => @galleries }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end
  end
end
