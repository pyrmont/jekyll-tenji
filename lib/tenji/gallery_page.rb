# frozen_string_literal: true

module Tenji

  # A page listing the images in a gallery
  #
  # {Tenji::GalleryPage} represents the index page within a gallery directory.
  # This class inherits from the `Jekyll::Page` class and is largely processed
  # by Jekyll like any other page in the website.
  #
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` parameter represents both
  # the directory name in the source directory and the directory name in the 
  # destination directory name. This is not necessarily the case in Tenji. See 
  # the {#initialize} documentation for more information.
  #
  # Another difference is that Tenji implements its own mechanism for
  # pagination, set out in the {Tenji::Pageable} module. See the
  # {Tenji::Pageable} documentation for more information.
  #
  # Finally, {Tenji::GalleryPage} includes the {Tenji::Processable} module. This
  # module contains common methods that are shared with other page objects in
  # the Tenji system (specifically {Tenji::ImagePage} and {Tenji::ListPage}).
  #
  # @since 0.1.0
  # @api private
  class GalleryPage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Pageable
    include Tenji::Processable

    # Initialise an object of this class
    #
    # As noted above, while the `dir` parameter represents the path to the
    # source directory, it does not necessarily represent the path to the
    # destination directory. There are two situations in which this occurs.
    #
    # The first is if the user prefixes the directory with an ordinal pattern
    # (eg. `01-`, `02-`) as a means of ordering the galleries. Tenji will use
    # this prefix to order the galleries in internal references but will remove
    # the prefix in the output.
    #
    # The second is is if the user has marked the gallery as `hidden`. In this
    # case, Tenji will generate an obfuscated name and use this in the
    # destination directory path. The obfuscation uses
    # `Base64#urlsafe_encode64` to transform the name.
    #
    # Tenji does not require that an actual index page exist for a particular
    # gallery. If the page does not exist, the value of `name` should be set to
    # `nil`. A gallery page will nevertheless be generated for each gallery. 
    #
    # @param site [Jekyll::Site] an object representing the Jekyll site
    # @param base [String] the base path
    # @param dir [String] the directory path
    # @param name [String, nil] the basename of the page (`nil` if the page does
    #   not exist)
    #
    # @return [Tenji::GalleryPage] the intialised object
    #
    # @since 0.1.0
    # @api private
    def initialize(site, base, dir, name)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

      @site = site
      @base = base
      @dir = dir
      @name = name ? name                       : 'index.html'
      @path = name ? File.join(base, dir, name) : ''

      read_file base, dir, name
      add_config

      process_dir config.dir(:galleries),
                  config.dir(:galleries, :out),
                  gallery_name,
                  output_gallery_name
      process_name

      paginate config.items_per_page(gallery_name)

      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self
    end

    # Duplicate the object
    #
    # As noted above, Tenji implements a different pagination mechanism than
    # that used by Jekyll. One of the key elements of this mechanism is the
    # creation of duplicates of the object. This method creates a duplicate and
    # ensures that the `data` instance variable is also duplicated.
    #
    # @param source [Tenji::GalleryPage] the object to be duplicated
    #
    # @return [Tenji::GalleryPage] the duplicated object
    #
    # @since 0.1.0
    # @api private
    def initialize_copy(source)
      super
      @data = source.data.dup
    end

    # Comparison operator
    #
    # {Tenji::GalleryPage} objects are compared on some combination of the 
    # period of the gallery and the name of the gallery. A user can configure 
    # whether the period is ignored and the direction in which periods and 
    # names are sorted.
    #
    # @param other [Tenji::GalleryPage] the object to compare
    #
    # @return [-1, 0, 1] the result of the comparison
    #
    # @since 0.1.0
    # @api private
    def <=>(other)
      this_start = data['period']&.first
      other_start = other.data['period']&.first

      name_sort = config.sort(:name)
      time_sort = config.sort(:time)

      if time_sort == :ignore || this_start == other_start
        (gallery_name <=> other.gallery_name) * name_sort
      elsif this_start.nil?
        1
      elsif other_start.nil?
        -1
      else
        (this_start <=> other_start) * time_sort
      end
    end

    # Assign an object to the `'cover'` key in the `@data` hash
    #
    # @param cover [Tenji::ThumbFile] the cover image for this gallery
    #
    # @since 0.1.0
    # @api private
    def cover=(cover)
      data['cover'] = cover
    end

    # Assign an object to the `'images'` key in the `@data` hash
    #
    # @param images [Array<Tenji::ImageFile>] the images in this gallery
    #
    # @since 0.1.0
    # @api private
    def images=(images)
      data['images'] = images
    end

    # Return the items used in pagination
    #
    # @return [Array<Tenji::ImageFile>] the images in this object
    #
    # @since 0.1.0
    # @api private
    def items()
      data['images']
    end

    # Assign the items used in pagination
    #
    # @param items [Array<Tenji::ImageFile>] the images in this object
    #
    # @since 0.1.0
    # @api private
    def items=(items)
      data['images'] = items
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
      data['layout'] ||= config.layout(:gallery, gallery_name)
      super(attrs)
    end

    # Add the configuration settings defined in frontmatter to the
    # {Tenji::Config} object
    #
    # @since 0.1.0
    # @api private
    private def add_config()
      config.add_config gallery_name, settings
    end

    # Parse the period set in the frontmatter
    #
    # The period should be written as two date strings with a hyphen (`-`)
    # separating the dates. Tenji parses the date strings using Ruby's
    # `Date::parse` method.
    #
    # @param period [String] the period as expressed as a string
    #
    # @return [Array<Time>] the components of the period
    #
    # @since 0.1.0
    # @api private
    private def parse_period(period)
      components = period.split '-'
      components.map { |c| Date.parse(c.strip) }
    end

    # Read the index file associated with the gallery
    #
    # @param base [String] the base path
    # @param dir [String] the directory
    # @param name [String] the basename of the file
    #
    # @since 0.1.0
    # @api private
    private def read_file(base, dir, name)
      if name.nil?
        @content = nil
        @data = Hash.new
      else
        read_yaml File.join(base, dir), name
        data['period'] = parse_period data['period'] if data['period']
      end
    end

    # Return the configuration settings included in the frontmatter data
    #
    # @return [Hash] the configuration settings
    #
    # @since 0.1.0
    # @api private
    private def settings()
      data.select { |k,v| config.settings(:gallery).key?(k) }
    end
  end
end
