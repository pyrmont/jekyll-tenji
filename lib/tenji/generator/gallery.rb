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

      def generate_images(files)
        files.is_a! Array
        return files unless @gallery.metadata['quality'] == 'original'
        @gallery.images.each do |i|
          files << Tenji::File::Image.new(i, @site, @base, @prefix_path, i.name)
        end
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        params = [ @gallery, @site, @base, @prefix_path, name ]
        pages << Tenji::Page::Gallery.new(*params)
      end

      def generate_individual_pages(pages)
        pages.is_a! Array
        return unless @gallery.metadata['individual_pages']
        @gallery.images.each do |i|
          pages << Tenji::Page::Image.new(i, @site, @base, @prefix_path, i.name)
        end
      end

      def generate_thumbs(files)
        files.is_a! Array

        factors = 1..Tenji::Config.option('scale_max')

        @gallery.images.each do |i|
          i.thumbs.each_value do |t|
            thumb_dir = Pathname.new Tenji::Config.dir(:thumbs)
            prefix_path = (thumb_dir + @gallery.dirname).to_s
            pos = t.name.rindex '.'
            factors.each do |f|
              fix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
              name = t.name.infix(pos, fix)
              files << Tenji::File::Thumb.new(@site, @base, prefix_path, name)
            end
          end
        end
      end
    end
  end
end
