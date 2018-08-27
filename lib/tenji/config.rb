# frozen_string_literal: true

module Tenji
  module Config
    using Tenji::Refinements

    DEFAULTS = { 
      'cover'               => { 'resize' => 'fill', 'x' => 200, 'y' => 200 },
      'galleries_dir'       => '_albums',
      'galleries_per_page'  => 10,
      'list_index'          => true,
      'scale_max'           => 2,
      'scale_suffix'        => '-#x',
      'sort'                => { 'name' => 'asc', 'period' => 'desc' },
      'thumbs_dir'          => '_thumbs',
      
      'gallery_settings'    => {
        'cover'           => nil,
        'hidden'          => false,
        'images_per_page' => 25,
        'layout'          => 'gallery_index',
        'original'        => true,
        'single_pages'    => true,
        'sizes'           => { 'small' => { 'resize' => 'fit', 'x' => 400 } },
        'sort'            => { 'name' => 'asc', 'period' => 'desc' }
      }
    }

    def self.inspect
      "<#{self.class} Tenji::Config>"
    end

    def self.configure(options = {})
      @config = defaults.deep_merge options
      @config.update({ 'gallery' => Hash.new { |h,k| h[k] = Hash.new } } )
    end

    def self.reset()
      @config = nil
    end

    def self.debug
      @config
    end

    def self.add_config(name, options)
      @config['gallery'][name] = options
    end

    def self.constraints(name, dirname = nil)
      settings = case name
                 when :cover
                   option('cover')
                 else
                   option('sizes', dirname)[name]
                 end
      settings.slice('x', 'y')
    end

    def self.cover(name)
      option('cover', name)
    end
    
    def self.dir(name)
      key = name.to_s + '_dir'
      dirname = option key
      dirname ? Tenji::Path.new(dirname) : nil
    end

    def self.hidden?(dirname)
      option('hidden', dirname)
    end

    def self.items_per_page(dirname = nil)
      if dirname
        option('images_per_page', dirname)
      else
        option('galleries_per_page')
      end
    end

    def self.option(name, dirname = nil)
      if dirname
        @config['gallery'][dirname][name] || @config['gallery_settings'][name]
      else
        @config[name]
      end
    end

    def self.resize_function(name, dirname = nil)
      settings = case name
                 when :cover
                   option('cover')
                 else
                   option('sizes', dirname)[name]
                 end
      settings['resize']
    end
    
    def self.scale_factors()
      1..option('scale_max')
    end

    def self.scale_suffix(factor)
      return '' if factor == 1
      option('scale_suffix').gsub('#', factor.to_s)
    end

    def self.set(name, value, dirname = nil)
      settings = (dirname) ? @config['gallery'][dirname] : @config

      if name.is_a? Array
        key = name.pop
        setting = name.reduce(settings) { |memo,k| memo.fetch(k) }
      else
        key = name
        setting = settings
      end

      setting[key] = value
    end

    def self.settings(name)
      key = name.to_s + '_settings'
      option(key)
    end

    def self.sort(type, dirname = nil)
      value = option('sort', dirname)[type]
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

    def self.thumb_sizes(dirname)
      option('sizes', dirname)
    end

    private_class_method def self.deep_copy(hsh)
      res = Hash.new
      hsh.each do |k,v|
        value = v.is_a?(Hash) ? deep_copy(v) : v.dup
        res[k] = value
      end
      res
    end

    private_class_method def self.defaults()
      deep_copy DEFAULTS
    end

    private_class_method def self.is_set!()
      raise Tenji::ConfigurationNotSetError unless @config
    end
  end
end
