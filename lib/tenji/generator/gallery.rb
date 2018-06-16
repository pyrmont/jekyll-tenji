require 'tenji/static_file'
require 'tenji/page/gallery'

module Tenji
  class Generator < Jekyll::Generator
    class Gallery
      attr_accessor :gallery, :site, :base, :prefix_path

      def initialize(gallery, site, base, prefix_path)
        @gallery = gallery
        @site = site
        @base = base
        @prefix_path = prefix_path
      end
      
      def generate_index()
        pages = Array.new
        pages << Tenji::Page::Gallery.new(@gallery, @site, @base, @prefix_path,
                                          'index.html')
      end

      def generate_photos()
        @gallery.images.map do |i|
          Tenji::StaticFile.new @site, @base, @prefix_path, i.name
        end
      end

      def generate_singles()
        @gallery.images.map do |i|
          Tenji::Page::Single.new i, @site, @base, @prefix_path
        end
      end

      def generate_thumbs()
        @gallery.images.map do |i|
          i.thumbs.files.map do |t|
            Tenji::StaticFile.new @site, @base, @prefix_path, t.name
          end
        end
      end
    end
  end
end
