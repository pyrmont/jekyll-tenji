module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirname, :images, :metadata, :text

    def initialize(dir:)
      dir.is_a! Pathname
      dir.exist!

      @dirname = dir.basename.to_s

      fm, text = self.class.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm, dir
      @text = text

      @images = init_images dir
    end

    private def init_images(dir)
      dir.is_a! Pathname

      dir.images.map do |i|
        Tenji::Gallery::Image.new i, @metadata['sizes']
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
      content = ''
      return [ data, content ] unless file.exist?

      filename = file.realpath.to_s
      begin
        content = ::File.read filename
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
