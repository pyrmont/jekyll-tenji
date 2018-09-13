# frozen_string_literal: true

module Tenji

  # A page displaying a gallery image
  #
  # {Tenji::ImagePage} represents the single page for a gallery image. This
  # class inherits from the `Jekyll::Page` class and is largely processed by
  # Jekyll like any other page in the website.
  # 
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` parameter represents both
  # the directory name in the source directory and the directory name in the 
  # destination directory name. This is not necessarily the case in Tenji. See 
  # the {#initialize} documentation for more information.
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
