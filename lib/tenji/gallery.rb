require 'tenji/gallery/image'
require 'tenji/gallery/metadata'
require 'tenji/gallery/page'
require 'tenji/refinements'

module Tenji
  class Gallery
    using Tenji::Refinements

    attr_accessor :metadata, :images
    
    def initialize(dir:)
      @metadata = init_metadata dir
      @images = init_images dir
    end

    private

    def init_images(dir)
      dir.images.map do |i|
        Tenji::Gallery::Image.new i
      end
    end

    def init_metadata(dir)
      file_path = dir + '_gallery.yml'
      Tenji::Gallery::Metadata.new file_path
    end
  end
end