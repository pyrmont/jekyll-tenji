require 'rmagick'

module Tenji
  class Gallery
    class Image
    
      attr_accessor :name
      
      def initialize(file)
        msg = "The file #{file} doesn't exist."
        raise StandardError, msg unless file.exist?

        @name = file.basename.to_s
      end
    end
  end
end
