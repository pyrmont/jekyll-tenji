# frozen_string_literal: true

module Tenji

  # A path to a file
  #
  # {Tenji::Path} is a thin wrapper around Ruby's [Pathname] class with
  # some minor changes to method names and return types to make them more
  # suitable for use with Tenji.
  #
  # @since 0.1.0
  # @api private
  class Path < Pathname
    using Tenji::Refinements

    # The file extensions that Tenji recognises as images
    #
    # @since 0.1.0
    # @api private
    IMAGE_EXTS = %w(.jpg .jpeg)

    # The file extensions that Tenji recognises as pages
    #
    # @since 0.1.0
    # @api private
    PAGE_EXTS = %w(.html .markdown .md)

    # The basenames that Tenji recognised as index pages
    #
    # @since 0.1.0
    # @api private
    INDEXES = PAGE_EXTS.map { |ext| 'index' + ext }
    
    # Initialise an object of this class
    #
    # @param p [#to_s] an object whose [String] representation is a path
    #
    # @return [Tenji::Path] the initialised object 
    #
    # @since 0.1.0
    # @api private
    def initialize(p)
      super p.to_s
    end

    # Return the concatenated path
    #
    # @param p [#to_s] an object whose [String] representation is a path
    #
    # @return [Tenji::Path] the concatenated path
    #
    # @since 0.1.0
    # @api private
    def +(p)
      Tenji::Path.new(super(p))
    end

    # Return the base of a path
    #
    # The 'base' here means the portion of the basename before the extension.
    #
    # @return [String] the base of the path
    #
    # @since 0.1.0
    # @api private
    def base()
      sub_ext('').basename.to_s
    end

    # Return paths to files that are located within the path
    #
    # @note This method only looks at the files immediately within the path.
    #
    # @return [Array<Tenji::Path>] the paths
    #
    # @since 0.1.0
    # @api private
    def files()
      children.select { |c| c.file? }
    end

    # Return whether this is a path to an image
    #
    # @return [Boolean] whether this path is an image
    #
    # @since 0.1.0
    # @api private
    def image?()
      IMAGE_EXTS.include? extname
    end

    # Return the index file that is within this path
    #
    # @note This method only looks at the files immediately within the path.
    #
    # @return [Tenji::Path, nil] the path to the index file or nil if there is
    #   no index file
    #
    # @since 0.1.0
    # @api private
    def index()
      INDEXES.find { |i| (self + i).exist? }&.yield_self { |i| self + i }
    end

    # Return whether this is a path to an index file
    #
    # @return [Boolean] whether this path is an index file
    #
    # @since 0.1.0
    # @api private
    def index?
      INDEXES.include? self.name
    end
    
    # Return the basename of this path
    #
    # @return [String] the basename of this path
    #
    # @since 0.1.0
    # @api private
    def name()
      basename.to_s
    end

    # Return whether this is a path to a page
    #
    # @return [Boolean] whether this path is a page
    #
    # @since 0.1.0
    # @api private
    def page?
      PAGE_EXTS.include? extname
    end

    # Return paths to directories that are located within the path
    #
    # @note This method only looks at the directories immediately within the 
    #   path.
    #
    # @return [Array<Tenji::Path>] the paths
    #
    # @since 0.1.0
    # @api private
    def subdirectories()
      children.select { |c| c.directory? }
    end
  end
end
