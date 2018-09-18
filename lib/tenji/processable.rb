# frozen_string_literal: true

module Tenji

  # A module for enabling processing of files on the disk
  #
  # {Tenji::Processable} is a module for sharing methods between the Tenji
  # objects that represent files on the disk.
  #
  # @since 0.1.0
  # @api private
  module Processable
    using Tenji::Refinements

    attr_accessor :config, :gallery_name

    # Equality operator
    #
    # This operator is necessary for testing purposes.
    #
    # @param other [Object] the object to compare
    #
    # @return [Boolean] the result of the comparison
    #
    # @since 0.1.0
    # @api private
    def ==(other)
      self.class == other.class &&
      self.instance_variables == other.instance_variables &&
      self.instance_variables.all? do |v|
        self.instance_variable_get(v) == other.instance_variable_get(v)
      end
    end

    # Return the destination path for this file
    #
    # Tenji allows a basename to include an ordinal pattern as a prefix (for
    # ordering purposes). The prefix is stripped when output and this method
    # enables that with a simple text substitution.
    #
    # @param dest [String] the path of the destination directory
    #
    # @return [String] the destination path
    #
    # @since 0.1.0
    # @api private
    def destination(dest)
      super(dest).sub(@name, output_name) 
    end

    # Return a simplified representation of the object as a String
    #
    # The default result of Object#inspect presents an excessive amount of
    # information. This method abbreviates some of the instance variables.
    #
    # @return [String] a representation of the object
    #
    # @since 0.1.0
    # @api private
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

    # Return the value of the `@path` instance variable
    #
    # @return [String] the path of the object
    #
    # @since 0.1.0
    # @api private
    def path
      @path
    end

    # Return the gallery name for output
    #
    # The name of a gallery's directory is not necessarily the same in the
    # destination directory as it is in the source directory. This method
    # returns the name for output.
    #
    # @return [String] the output gallery name
    #
    # @since 0.1.0
    # @api private
    private def output_gallery_name()
      res = gallery_name.sub(/^\d+-/, '')
      return res unless config.hidden?(gallery_name)
      Base64.urlsafe_encode64(res, padding: false)
    end

    # Return the basename for output
    #
    # The basename of a file is not necessarily the same in the destination
    # directory as it is in the source directory. This method returns the name
    # for output.
    #
    # @return [String] the output basename
    #
    # @since 0.1.0
    # @api private
    private def output_name()
      @name.sub(/^\d+-/, '')
    end
    
    # Return the directory as a Tenji::Path
    #
    # @param dir [String] a path as a String
    #
    # @return [Tenji::Path] the path
    #
    # @since 0.1.0
    # @api private
    private def pathify(dir)
      Tenji::Path.new(dir)
    end
    
    # Set the parent path for use in the destination directory
    #
    # The parent path consists of the top-level directory and the directory for
    # the gallery. The parent path used in the destination directory is not
    # the same as the parent path used in the source directory. This method sets
    # that up.
    #
    # @param t_in [String] the top-level directory used for input
    # @param t_out [String] the top-level directory used for output
    # @param g_in [String] the gallery directory used for input
    # @param g_out [String] the gallery directory used for output
    #
    # @since 0.1.0
    # @api private
    private def process_dir(t_in, t_out, g_in = '', g_out = '')
      @dir = @dir.sub(t_in, t_out)
      @dir = @dir.sub(g_in, g_out)
    end
    
    # Set the basename for use in the destination directory
    #
    # @since 0.1.0
    # @api private
    private def process_name()
      process name
      basename = output_name[0..-ext.length - 1]
    end
  end
end
