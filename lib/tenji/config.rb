module Tenji
  module Config
    DEFAULTS = { 'galleries_dir' => '_albums',
                 'thumbs_dir' => '_thumbs',
                 'metadata_file' => 'index.md',
                 'input_page_ext' => '.md',
                 'output_page_ext' => '.html' }

    def self.configure(options = {})
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

    def self.is_set!()
      raise StandardError, 'Configuration not set' unless @config
    end

    def self.settings(name)
      is_set!
      key = name.to_s + '_settings'
      @config[key]
    end
  end
end
