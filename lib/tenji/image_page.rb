# frozen_string_literal: true

module Tenji

  # A page displaying a gallery image
  #
  # {Tenji::ImagePage} represents the single page for a gallery image. This
  # class inherits from the `Jekyll::Page` class and is largely processed by
  # Jekyll like any other page in the website.
  # 
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` and `name` parameters represent 
  # the names in the source directory and the names in the destination
  # directory. This is not the case in Tenji. See the {#initialize} 
  # documentation for more information.
  #
  # Finally, {Tenji::ImageFile} includes the {Tenji::Processable} module. This
  # module contains common methods that are shared with other objects that
  # produce output.
  #
  # @since 0.1.0
  # @api private
  class ImagePage < Jekyll::Page
    using Tenji::Refinements

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
    # At a minimum, this is true in respect of the portion of `dir` that
    # includes the name of the top-level galleries directory. To avoid Jekyll 
    # processing this directory and its contents independent of Tenji, the 
    # directory must be prefixed with an `_`. This prefix is stripped when
    # output (eg. `_albums` becomes `albums`).
    #
    # In addition, if the user prefixes the gallery directory's name with an 
    # ordinal pattern (eg. `01-`, `02-`) as a means of ordering the galleries,
    # this pattern will be stripped when output.
    #
    # Finally, if the user has marked the gallery as `hidden`, Tenji will 
    # generate an obfuscated name and use this for the gallery's name in the
    # destination directory. Tenji uses [`Base64#urlsafe_encode64`][doc] to 
    # transform the name.
    #
    # [doc]: https://ruby-doc.org/stdlib/libdoc/base64/rdoc/Base64.html#method-i-urlsafe_encode64
    #
    # The situation with respect to `name` is different. If the name of the file
    # includes an ordinal pattern as a prefix, the file's name in the source
    # directory will differ from that in the name in the destination directory.
    # However, if there is no such ordinal pattern as a prefix, the names will
    # be the same.
    #
    # @param site [Jekyll::Site] an object representing the Jekyll site
    # @param base [String] the base path
    # @param dir [String] the directory path
    # @param name [String] the basename of the page 
    #
    # @return [Tenji::ImagePage] the initialised object
    #
    # @since 0.1.0
    # @api private
    def initialize(site, base, dir, name)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

      @site = site
      @base = base
      @dir = dir
      @name = name
      @path = File.join(base, dir, name)

      read_file base, dir, name

      process_dir config.dir(:galleries),
                  config.dir(:galleries, :out),
                  gallery_name,
                  output_gallery_name
      process_name 
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    # Assign an object to the `'image'` key in the `@data` hash
    #
    # @param image [Tenji::ImageFile] the gallery image for this page
    #
    # @since 0.1.0
    # @api private
    def image=(image)
      @data['image'] = image
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
      data['layout'] ||= config.layout(:single, gallery_name)
      data['next'] = data['image'].image_next&.data&.fetch('page')
      data['prev'] = data['image'].image_prev&.data&.fetch('page')
      super(attrs)
    end

    # Read the file
    #
    # @param base [String] the base path
    # @param dir [String] the directory
    # @param name [String] the basename of the file
    #
    # @since 0.1.0
    # @api private
    private def read_file(base, dir, name)
      if File.exist?(File.join(base, dir, name))
        read_yaml File.join(base, dir), name
      else
        @content = nil
        @data = Hash.new
      end
    end
  end
end
