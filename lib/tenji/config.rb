# frozen_string_literal: true

module Tenji

  # A store of the configuration options for Tenji
  #
  # @note This document describes the operation of the {Tenji::Config} class.
  #   For information on how to configure Tenji, see {file:docs/Configuring.md}.
  #
  # {Tenji::Config} allows for transparent access to Tenji's configuration
  # options. If the requested option has not been set by the user,
  # {Tenji::Config}'s methods will return the default value.
  #
  # As a means of consistently sharing state, data is stored in an instance
  # variable on {Tenji::Config}'s singleton class and should be accessed via
  # the defined class methods. When debugging, the internal structure can be
  # accessed via {Tenji::Config.debug}.
  #
  # @since 0.1.0
  # @api private
  module Config
    using Tenji::Refinements

    # The default options
    #
    # @since 0.1.0
    # @api private
    DEFAULTS = {
      'cover'               => { 'resize' => 'fill', 'x' => 200, 'y' => 200 },
      'galleries_dir'       => '_albums',
      'galleries_per_page'  => 10,
      'layout_list'         => 'gallery_list',
      'list_index'          => true,
      'scale_max'           => 2,
      'scale_suffix'        => '-#x',
      'sort'                => { 'name' => 'desc', 'time' => 'desc' },
      'thumbs_dir'          => '_thumbs',

      'gallery_settings'    => {
        'cover'           => nil,
        'downloadable'    => true,
        'hidden'          => false,
        'images_per_page' => 25,
        'layout_gallery'  => 'gallery_index',
        'layout_single'   => 'gallery_single',
        'single_pages'    => true,
        'sizes'           => { 'small' => { 'resize' => 'fit', 'x' => 400 } },
        'sort'            => { 'name' => 'asc', 'time' => 'asc' }
      }
    }

    # Return a minimal summary of the class
    #
    # @note The method {.debug} can be used to return the internal data
    #   structure.
    #
    # @return [String] the text summary
    #
    # @since 0.1.0
    # @api private
    def self.inspect
      "<#{self.class} Tenji::Config>"
    end

    # Initialise the configuration options
    #
    # @param options [Hash] custom options that will overwrite the defaults
    #
    # @since 0.1.0
    # @api private
    def self.configure(options = nil)
      options ||= Hash.new
      @config = defaults.deep_merge(options)
      @config.update({ 'gallery' => Hash.new { |h,k| h[k] = Hash.new } } )
    end

    # Clear the configuration options
    #
    # @since 0.1.0
    # @api private
    def self.reset()
      @config = nil
    end

    # Return the internal data structure used to hold the configuration options
    #
    # @return [Hash] the data structure holding the configuration options
    #
    # @since 0.1.0
    # @api private
    def self.debug
      @config
    end

    # Add configuration options for the given gallery
    #
    # @param name [String] the name of the directory for the given gallery
    # @param options [Hash] the options
    #
    # @since 0.1.0
    # @api private
    def self.add_config(name, options)
      @config['gallery'][name] = options
    end

    # Return the size constraints for the given thumbnail size
    #
    # @param name [:cover, String] the name of the thumbnail size
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Hash<String, Integer>] a hash with keys `x` and `y` specifying
    #   the width and height constraints respectively
    #
    # @raise [Tenji::Config::NotGalleryLevelError] if `dirname` is provided when
    #   `name` is `:cover`
    #
    # @since 0.1.0
    # @api private
    def self.constraints(name, dirname = nil)
      case name
      when :cover
        raise NotGalleryLevelError if dirname
        option('cover')
      else
        option('sizes', dirname)[name]
      end.slice('x', 'y')
    end

    # Return the filename of the image to use as a cover for the given gallery
    #
    # @note The filename does not contain the full path to the file.
    #
    # @param name [String] the directory name of the gallery
    #
    # @return [String] if a filename has been specified
    # @return [nil] if a filename has not been specified
    #
    # @since 0.1.0
    # @api private
    def self.cover(name)
      option('cover', name)
    end

    # Return the directory name
    #
    # @param name [:galleries, :thumbs] the key
    # @param output [:out] whether to return the directory name that will be
    #   used for output
    #
    # @return [String] the name of the directory
    #
    # @raise [Tenji::Config::NoKeyError] if no directory name is defined
    #   the `key`
    #
    # @since 0.1.0
    # @api private
    def self.dir(name, output = nil)
      key = name.to_s + '_dir'
      dirname = option key

      raise NoKeyError if dirname.nil?

      if output == :out
        dirname.slice(1..-1)
      else
        dirname
      end
    end

    # Return whether files in the given directory are downloadable
    #
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Boolean] whether the files are downloadable
    #
    # @since 0.1.0
    # @api private
    def self.downloadable?(dirname)
      option('downloadable', dirname)
    end

    # Return whether the given gallery is hidden
    #
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Boolean] whether the gallery is hidden
    #
    # @since 0.1.0
    # @api private
    def self.hidden?(dirname)
      option('hidden', dirname)
    end

    # Returns the number of items per page of a document
    #
    # If `dirname` is provided, this will return the number of images to be
    # displayed per page for the given gallery. If `dirname` is not provided,
    # this will return the number of galleries to be displayed per page of the
    # gallery list.
    #
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Integer] if the document should be paginated, the number of
    #   items per page
    # @return [false] if the document should not be paginated, false
    #
    # @since 0.1.0
    # @api private
    def self.items_per_page(dirname = nil)
      if dirname
        option('images_per_page', dirname)
      else
        option('galleries_per_page')
      end
    end

    # Return the name of the layout to be used for a document
    #
    # @param type [:list, :gallery, :single] the document type
    # @param dirname [String] the directory name of the gallery
    #
    # @return [String] the name of the layout
    #
    # @raise [Tenji::Config::NoDocumentError] if the document type does not
    #   exist
    #
    # @since 0.1.0
    # @api private
    def self.layout(type, dirname = nil)
      types = [ :list, :gallery, :single ]
      raise NoDocumentError unless types.include?(type)

      key = 'layout_' + type.to_s
      option(key, dirname)
    end

    # Return whether to generate a list index
    #
    # By default, Tenji will generate a separate page listing the non-hidden
    # galleries. For a website that is only for images, this may be
    # unnecessary. In this case, a user may wish to disable the list page.
    #
    # @return [Boolean] whether to generate a list index
    #
    # @since 0.1.0
    # @api private
    def self.list?()
      option('list_index')
    end

    # Return a Tenji::Path object representing the given directory name
    #
    # @param name [String] the directory name of the gallery
    #
    # @return [Tenji::Path] a Tenji::Path object representing the given directory name
    #
    # @since 0.1.0
    # @api private
    def self.path(name)
      dirname = self.dir name
      dirname ? Tenji::Path.new(dirname) : nil
    end

    # Return the name of the resize function
    #
    # Thumbnails are generated using ImageMagick's resize function. There are
    # two different resize functions supported by Tenji: (1) 'fill'; and (2)
    # 'fit'.
    #
    # @param name [:cover, String] the name of the thumbnail size
    # @param dirname [String] the directory name of the gallery
    #
    # @return [String] the name of the function
    #
    # @raise [Tenji::Config::NoSizeError] if there is no function for the
    #   given size
    #
    # @since 0.1.0
    # @api private
    def self.resize_function(name, dirname = nil)
      case name
      when :cover
        option('cover')
      else
        res = option('sizes', dirname)
        raise NoSizeError if res[name].nil?
        res[name]
      end.fetch('resize')
    end

    # Return a range of scaling factors
    #
    # @return [Range] the scaling factors
    #
    # @since 0.1.0
    # @api private
    def self.scale_factors()
      1..option('scale_max')
    end

    # Return the suffix to use for a given scaling factor
    #
    # @note The empty string is returned when the scaling factor is 1.
    #
    # When it creates thumbnails for different display densities, Tenji appends
    # a suffix to the filename of the thumbnail. A user can customise the format
    # of the suffix by setting the key `suffix_format`.
    #
    # @param factor [Integer] the scaling factor
    #
    # @return [String] the suffix
    #
    # @since 0.1.0
    # @api private
    def self.scale_suffix(factor)
      return '' if factor == 1
      option('scale_suffix').gsub('#', factor.to_s)
    end

    # Set the value for a given key
    #
    # @note A nested key can be set by passing an array as the first parameter
    #
    # @param name [Array, String] the key (if the key is nested, each level of
    #   key can be passed as succeeding items in an array)
    # @param value [Object] the value to set
    # @param dirname [String] the directory name of the gallery
    #
    # @since 0.1.0
    # @api private
    def self.set(name, value, dirname = nil)
      settings = (dirname) ? @config['gallery'][dirname] : @config

      if name.is_a? Array
        key = name.pop
        settings = name.reduce(settings) { |memo,k| memo.fetch(k) }
      else
        key = name
      end

      settings[key] = value
    end

    # Return settings for the given gallery type
    #
    # @note Tenji currently only supports one gallery type.
    #
    # @param type [:gallery] the gallery type
    #
    # @return [Hash] a hash of settings
    #
    # @raise [Tenji::Config::NoGalleryTypeError] if the type is not one of the 
    #   supported types
    #
    # @since 0.1.0
    # @api private
    def self.settings(type)
      raise NoGalleryTypeError unless [ :gallery ].include?(type)
      key = type.to_s + '_settings'
      option(key)
    end

    # Return whether pages should be generated for individual images in the
    # given gallery
    #
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Boolean] whether pages should be generated for individual images
    #
    # @since 0.1.0
    # @api private
    def self.single_pages?(dirname)
      option('single_pages', dirname)
    end

    # Return a toggle to adjust the sort order for the given type
    #
    # Tenji sorts galleries and images using the `#<=>` method. This method
    # returns `-1`, `0` or `1` when comparing against another object. The sort
    # order can be adjusted by multiplying this number by a toggle.
    #
    # @param type [:name, :time] the sort type
    # @param dirname [String] the directory name of the gallery
    #
    # @return [:ignore, -1, 1] the toggle
    #
    # @raise [Tenji::Config::NoSortTypeError] if the given sort type does not 
    #   exist
    # @raise [Tenji::Config::InvalidSortError] if the value for the sort set in
    #   the configuration file is invalid
    #
    # @since 0.1.0
    # @api private
    def self.sort(type, dirname = nil)
      raise NoSortTypeError unless [:name, :time].include?(type)

      value = option('sort', dirname)[type.to_s].downcase

      case value
      when 'ignore'
        type == :time ? :ignore : raise(InvalidSortError)
      when 'asc'
        1
      when 'desc'
        -1
      else
        raise InvalidSortError
      end
    end

    # Return the configuration options for all the thumbnail sizes for the given
    # gallery
    #
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Hash] the options for all thumbnail sizes
    #
    # @since 0.1.0
    # @api private
    def self.thumb_sizes(dirname)
      option('sizes', dirname)
    end

    # Return the default options as an object with no shared references
    #
    # @return [Hash] the default options
    #
    # @since 0.1.0
    # @api private
    private_class_method def self.defaults()
      DEFAULTS.deep_copy
    end

    # Return the option for the given key
    #
    # @param key [String] the key
    # @param dirname [String] the directory name of the gallery
    #
    # @return [Object] the value of the option
    #
    # @since 0.1.0
    # @api private
    private_class_method def self.option(key, dirname = nil)
      if dirname
        value = @config['gallery'][dirname][key]
        value.nil? ? @config['gallery_settings'][key] : value
      else
        @config[key]
      end
    end
  end
end
