# frozen_string_literal: true

module Tenji
  
  # A page listing the galleries
  #
  # @note {Tenji::ListPage} does not list the galleries that are hidden.
  #
  # {Tenji::ListPage} represents the index page in the galleries directory.
  # This class inherits from the `Jekyll::Page` class and is largely processed
  # by Jekyll like any other page in the website.
  #
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` parameter represents both
  # the directory name in the source directory and the directory name in the 
  # destination directory. This is not the case in Tenji. See the {#initialize}
  # documentation for more information.
  #
  # Another difference is that Tenji implements its own mechanism for
  # pagination, set out in the {Tenji::Pageable} module. See the
  # {Tenji::Pageable} documentation for more information.
  #
  # Finally, {Tenji::ListPage} includes the {Tenji::Processable} module. This
  # module contains common methods that are shared with other objects that
  # produce output.
  #
  # @since 0.1.0
  # @api private
  class ListPage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Pageable
    include Tenji::Processable

    # Initialise an object of this class
    #
    # @note The parameter name `dir` is misleading. It has been retained for
    #   consistency with the parent class. While the name suggests it is a
    #   directory name, it is instead the path to the parent of the file
    #   relative to `base`.
    #
    # As noted above, while the `dir` parameter is a component of the path in
    # the source directory, it is not a component of the path in the destination
    # directory.
    #
    # This is the case in respect of the portion of `dir` that includes the name
    # of the top-level galleries directory. To avoid Jekyll processing this 
    # directory and its contents independent of Tenji, the directory must be 
    # prefixed with an `_`. This prefix is stripped when output (eg. `_albums` 
    # becomes `albums`).
    #
    # @param site [Jekyll::Site] an object representing the Jekyll site
    # @param base [String] the base path
    # @param dir [String] the directory path
    # @param name [String, nil] the basename of the page (`nil` if the page does
    #   not exist)
    #
    # @return [Tenji::ListPage] the initialised object
    #
    # @since 0.1.0
    # @api private
    def initialize(site, base, dir, name)
      @config = Tenji::Config

      @site = site
      @base = base
      @dir = dir
      @name = name ? name                       : 'index.html'
      @path = name ? File.join(base, dir, name) : ''

      read_file base, dir, name

      process_dir config.dir(:galleries), config.dir(:galleries, :out)
      process_name 
      
      paginate config.items_per_page
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    # Assign an object to the `'galleries'` key in the `@data` hash
    #
    # @param galleries [Array<Tenji::GalleryPage>] the galleries to be listed
    #
    # @since 0.1.0
    # @api private
    def galleries=(galleries)
      @data['galleries'] = galleries
    end

    # Return the items used in pagination
    #
    # @return [Array<Tenji::GalleryPage>] the galleries in this object
    #
    # @since 0.1.0
    # @api private
    def items()
      data['galleries']
    end

    # Assign the items used in pagination
    #
    # @param galleries [Array<Tenji::GalleryPage>] the galleries in this object
    #
    # @since 0.1.0
    # @api private
    def items=(galleries)
      data['galleries'] = galleries
    end
    
    # Convert this object to a hash for use in Liquid templates
    #
    # @param attrs [Hash] a legacy parameter defined in `Jekyll:Page`
    #
    # @return [Hash] the representation of this object as a hash
    #
    # @since 0.1.0
    # @api private
    def to_liquid(attrs = nil)
      data['layout'] ||= config.layout(:list)
      super(attrs)
    end
    
    # Read the index file associated with the listing
    #
    # @param base [String] the base path
    # @param dir [String] the directory
    # @param name [String] the basename of the file
    #
    # @since 0.1.0
    # @api private
    private def read_file(base, dir, name) 
      if name.nil?
        @content = ''
        @data = Hash.new
      else
        read_yaml File.join(base, dir), name
      end
    end
  end
end
