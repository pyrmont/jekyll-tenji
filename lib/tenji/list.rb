module Tenji
  class List
    using Tenji::Refinements

    attr_reader :dirname, :galleries, :metadata, :text

    def initialize(dir:)
      dir.is_a! Pathname
      dir.exist!

      @dirname = dir.basename.to_s
      @galleries = init_galleries dir

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm
      @text = text
    end

    private def init_galleries(dir)
      dir.subdirectories.map do |d|
        Tenji::Gallery.new dir: d
      end
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
    end
  end
end
