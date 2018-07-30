# frozen_string_literal: true

module Tenji
  module Config
    using Tenji::Refinements

    DEFAULTS = { 'galleries_dir' => '_albums',
                 'thumbs_dir' => '_thumbs',
                 'metadata_file' => 'index.md',
                 'input_page_ext' => '.md',
                 'output_page_ext' => '.html',
                 'scale_max' => 2,
                 'scale_suffix_format' => '-#x',
                 'list_index' => true,
                 'sort' => { 'name' => 'asc', 'period' => 'desc' } }

    def self.configure(options = {})
      options.is_a! Hash
      @config = DEFAULTS.deep_merge options
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

    def self.sort(type)
      is_set!
      value = @config['sort'][type]
      if type == 'period' && value == 'ignore'
        :ignore
      elsif value.downcase == 'asc'
        1
      elsif value.downcase == 'desc'
        -1
      else
        msg = "Sort value for #{type} in configuration file is invalid"
        raise Tenji::ConfigurationError, msg
      end
    end

    def self.suffix(type, factor: nil)
      is_set!

      if type.to_s == 'scale'
        msg = 'Scale must be an Integer'
        raise ::ArgumentError, msg unless factor.is_a? Integer
        key = type.to_s + '_suffix_format'
        @config[key]&.sub('#', factor.to_s)
      else
        nil
      end
    end

    private_class_method def self.is_set!()
      raise Tenji::ConfigurationNotSetError unless @config
    end
  end
end
