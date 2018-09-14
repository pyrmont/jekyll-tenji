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

    def destination(dest)
      super(dest).sub(@name, output_name) 
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

    private def output_gallery_name()
      res = gallery_name.sub(/^\d+-/, '')
      return res unless config.hidden?(gallery_name)
      Base64.urlsafe_encode64(res, padding: false)
    end

    private def output_name()
      @name.sub(/^\d+-/, '')
    end
    
    private def pathify(dir)
      Tenji::Path.new(dir)
    end
    
    private def process_dir(t_in, t_out, g_in = '', g_out = '')
      @dir = @dir.sub(t_in, t_out)
      @dir = @dir.sub(g_in, g_out)
    end
    
    private def process_name()
      process name
      basename = output_name[0..-ext.length - 1]
    end
  end
end
