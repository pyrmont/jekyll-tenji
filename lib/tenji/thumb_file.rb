# frozen_string_literal: true

module Tenji

  # A thumbnail image of an image in a gallery
  #
  # {Tenji::ThumbFile} represents a thumbnail image of an image located within a
  # gallery. This class inherits from the `Jekyll::StaticFile` class and is
  # largely processed by Jekyll like any other static file in the website.
  #
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` and `name` parameters represent 
  # the names in the source directory and the names in the destination
  # directory. This is not the case in Tenji. See the {#initialize} 
  # documentation for more information.
  #
  # {Tenji::ImageFile} also includes the {Tenji::Processable} module. This
  # module contains common methods that are shared with other objects that
  # produce output.
  #
  # @since 0.1.0
  # @api private
  class ThumbFile < Jekyll::StaticFile
    using Tenji::Refinements

    include Tenji::Processable

    attr_accessor :source_path

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
    # @param name [String] the basename of the image 
    #
    # @return [Tenji::ThumbFile] the initialised object
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

      process_dir config.dir(:thumbs),
                  config.dir(:galleries, :out), 
                  gallery_name,
                  File.join(output_gallery_name, config.dir(:thumbs, :out))

      @relative_path = File.join(@dir, output_name)
      @extname = File.extname(@name)
      @data = @site.frontmatter_defaults.all(relative_path, type)
    end

    # Convert this object to a hash for use in Liquid templates
    #
    # @return [Hash] the representation of this object as a hash
    #
    # @since 0.1.0
    # @api private
    def to_liquid()
      @data['url'] = url
      super
    end

    # Write different copies of this image for each scaling factor
    #
    # Rather than have separate {Tenji::ThumbFile} objects that would otherwise
    # be identical for each scaling factor, Tenji maintains a single 
    # {Tenji::ThumbFile} for the respective thumbnail size and then overrides
    # `Jekyll::StaticFile#write` to write copies for each scaling factor.
    #
    # @param dest [String] the path to the destination directory
    #
    # @since 0.1.0
    # @api private
    def write(dest)
      original_name = @name
      original_path = @path

      config.scale_factors.each do |f|
        @name = @name.append_to_base(config.scale_suffix(f))
        @path = @path.append_to_base(config.scale_suffix(f))
        super(dest)
      end

      @name = original_name
      @path = original_path
    end
  end
end
