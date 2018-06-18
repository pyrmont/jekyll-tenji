require 'tenji/gallery/image'
require 'tenji/gallery/metadata'
require 'tenji/refinements'

module Tenji
  class Gallery
    using Tenji::Refinements

    METADATA_FILE = '_gallery.md'

    attr_reader :images, :metadata, :text

    def initialize(dir:)
      dir.is_a! Pathname
      dir.exist!

      fm, text = self.class.read_yaml(dir + METADATA_FILE)
      @metadata = init_metadata fm, dir
      @text = text

      @images = init_images dir
    end

    private def init_images(dir)
      dir.is_a! Pathname

      dir.images.map do |i|
        Tenji::Gallery::Image.new i
      end
    end

    private def init_metadata(frontmatter, dir)
      frontmatter.is_a! Hash
      dir.is_a! Pathname
      Tenji::Gallery::Metadata.new frontmatter, dir.basename.to_s
    end

    def self.read_yaml(file, config = {})
      file.is_a! Pathname
      config.is_a! Hash

      data = Hash.new
      content = nil
      return [ data, content ] unless file.exist?

      filename = file.realpath.to_s
      begin
        content = File.read filename
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          content = $POSTMATCH
          data = SafeYAML.load Regexp.last_match(1)
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      rescue StandardError => e
        Jekyll.logger.warn "Error reading file #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      end

      [ data, content ]
    end

  end
end
