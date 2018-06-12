require 'rmagick'

module Tenji
  class Gallery

    attr_accessor :name

    class Image
      def initialize(file)
        msg = "The file #{file} doesn't exist."
        raise StandardError, msg unless file.exist?
      end
    end
  end
end
