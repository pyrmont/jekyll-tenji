require 'pathname'
require 'tenji/page/gallery'
require 'tenji/static_file'
require 'tenji/verify'

module Tenji
  class Generator < Jekyll::Generator
    class Gallery
      include Tenji::Verify

      attr_accessor :gallery, :site, :base, :prefix_path

      def initialize(gallery, site, base, prefix_path)
        verify [ gallery, Tenji::Gallery ],
               [ site, Jekyll::Site ],
               [ base, Pathname ],
               [ prefix_path, Pathname ]
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
          i.thumbs.files.map do |key,value|
            path = Pathname.new value
            Tenji::StaticFile.new @site, @base, @prefix_path, path.basename.to_s
          end
        end
      end
    end
  end
end
