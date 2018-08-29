# frozen_string_literal: true

module Tenji
  class Path < Pathname
    using Tenji::Refinements

    IMAGE_EXTS = %w(.jpg .jpeg)
    PAGE_EXTS = %w(.html .markdown .md)
    INDEXES = PAGE_EXTS.map { |ext| 'index' + ext }
    
    def initialize(p)
      super p.to_s
    end

    def +(p)
      Tenji::Path.new(super(p))
    end

    def base()
      sub_ext('').basename.to_s
    end

    def files()
      children.select { |c| c.file? }
    end

    def image?()
      IMAGE_EXTS.include? extname
    end

    def index()
      INDEXES.find { |i| (self + i).exist? }&.yield_self { |i| self + i }
    end

    def index?
      INDEXES.include? self.name
    end
    
    def name()
      basename.to_s
    end

    def page?
      PAGE_EXTS.include? extname
    end

    def subdirectories()
      children.select { |c| c.directory? }
    end
  end
end
