module Tenji
  class Generator < Jekyll::Generator
    class Gallery
      using Tenji::Refinements

      attr_reader :gallery, :site, :base, :prefix_path

      def initialize(gallery, site, base, prefix_path)
        gallery.is_a! Tenji::Gallery
        site.is_a! Jekyll::Site
        base.is_a! Pathname
        prefix_path.is_a! Pathname

        @gallery = gallery
        @site = site
        @base = base.to_s
        @prefix_path = prefix_path.to_s
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        pages << Tenji::Page::Gallery.new(@gallery, @site, @base, @prefix_path, name)
      end

      def generate_photos(files)
        files.is_a! Array
        @gallery.images.each do |i|
          files << Tenji::File::Image.new(@site, @base, @prefix_path, i.name)
        end
      end

      def generate_singles(pages)
        pages.is_a! Array
        return Array.new unless @gallery.metadata['singles']
        @gallery.images.each do |i|
          pages << Tenji::Page::Image.new(i, @site, @base, @prefix_path, 
                                          i.name)
        end
      end

      def generate_thumbs(files)
        files.is_a! Array

        @gallery.images.each do |i|
          i.thumbs.files.map do |key,value|
            thumb_dir = Pathname.new Tenji::Config.dir(:thumbs)
            prefix_path = (thumb_dir + @gallery.dirname).to_s
            files << Tenji::File::Thumb.new(@site, @base, prefix_path, value)
          end
        end
      end
    end
  end
end
