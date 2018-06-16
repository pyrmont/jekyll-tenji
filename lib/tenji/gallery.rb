require 'tenji/gallery/image'
require 'tenji/gallery/metadata'
require 'tenji/refinements'

module Tenji
  class Gallery
    using Tenji::Refinements

    METADATA_FILE = '_gallery.md'

    attr_accessor :images, :metadata, :text

    def initialize(dir:)
      msg = "The directory #{dir} does not exist."
      raise StandardError, msg unless dir.exist?

      fm, text = Tenji::Gallery.read_yaml(dir + METADATA_FILE)
      @metadata = init_metadata fm, dir
      @text = text

      @images = init_images dir
    end

    private def init_images(dir)
      dir.images.map do |i|
        Tenji::Gallery::Image.new i
      end
    end

    private def init_metadata(frontmatter, dir)
      Tenji::Gallery::Metadata.new frontmatter, dir.basename.to_s
    end

    def self.read_yaml(file, config = {})
      return nil, nil unless file.exist?

      filename = file.realpath.to_s

      begin
        content = File.read filename
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          content = $POSTMATCH
          data = SafeYAML.load Regexp.last_match(1)
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        # raise e if config["strict_front_matter"]
        raise e
      rescue StandardError => e
        Jekyll.logger.warn "Error reading file #{filename}: #{e.message}"
        # raise e if config["strict_front_matter"]
        raise e
      end

      [ data, content ]
    end

  end
end
