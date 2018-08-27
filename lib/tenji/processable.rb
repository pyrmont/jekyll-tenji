# frozen_string_literal: true

module Tenji
  module Processable
    using Tenji::Refinements

    attr_accessor :config, :gallery_name

    def ==(other)
      self.class == other.class &&
      self.instance_variables == other.instance_variables &&
      self.instance_variables.all? do |v|
        self.instance_variable_get(v) == other.instance_variable_get(v)
      end
    end

    def inspect()
      ivar_list = instance_variables.map do |v|
                    val = instance_variable_get(v)
                    if val.class == Jekyll::Site
                      "#{v}=<#{val.class}>"
                    else
                      "#{v}=#{val.inspect}"
                    end
                  end.join(' ')
      "<#{self.class} #{ivar_list}>"
    end

    def path
      @path
    end

    private def output_gallery_name(str)
      res = str.sub(/^\d+-/, '')
      return res unless config.hidden?(gallery_name)
      Base64.urlsafe_encode64(res, padding: false)
    end
    
    private def pathify(dir)
      Tenji::Path.new(dir)
    end
    
    private def process_dir()
      in_t = config.dir(:galleries).to_s
      out_t = in_t.slice(1..-1)
      in_g = gallery_name
      out_g = output_gallery_name(in_g)
      @dir = @dir.sub(in_t, out_t).sub(in_g, out_g)
    end
    
    private def process_name()
      process name
    end
  end
end
