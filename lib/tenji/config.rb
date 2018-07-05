module Tenji
  module Config
    using Tenji::Refinements

    DEFAULTS = { 'galleries_dir' => '_albums',
                 'thumbs_dir' => '_thumbs',
                 'metadata_file' => 'index.md',
                 'scale_max' => 2,
                 'scale_suffix_format' => '-#x',
                 'input_page_ext' => '.md',
                 'output_page_ext' => '.html' }

    def self.configure(options = {})
      options.is_a! Hash
      @config = DEFAULTS.merge options
    end

    def self.reset()
      @config = nil
    end

    def self.config
      is_set!
      @config
    end

    def self.dir(name, output: false)
      is_set!
      key = name.to_s + '_dir'
      (output) ? @config[key].delete_prefix('_') : @config[key]
    end

    def self.ext(name, output: false)
      is_set!
      key = (output) ? 'output_' + name.to_s + '_ext' :
                       'input_' + name.to_s + '_ext'
      @config[key]
    end

    def self.file(name)
      is_set!
      key = name.to_s + '_file'
      @config[key]
    end

    def self.option(name)
      is_set!
      @config[name]
    end

    def self.settings(name)
      is_set!
      key = name.to_s + '_settings'
      @config[key]
    end

    def self.suffix(type, factor: nil)
      is_set!
      if type.to_s == 'scale'
        key = type.to_s + '_suffix_format'
        @config[key].sub('#', factor.to_s)
      else
        nil
      end
    end

    private_class_method def self.is_set!()
      raise StandardError, 'Configuration not set' unless @config
    end
  end
end
