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
        @gallery.images.each do |i|
          files << Tenji::File::Image.new(@site, @base, @prefix_path, i.name)
        end
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        pages << Tenji::Page::Gallery.new(@gallery,
                                          @site,
                                          @base,
                                          @prefix_path,
                                          name)
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

        @gallery.images.each do |i|
          i.thumbs.each_value do |t|
            thumb_dir = Pathname.new Tenji::Config.dir(:thumbs)
            prefix_path = (thumb_dir + @gallery.dirname).to_s
            files << Tenji::File::Thumb.new(@site, @base, prefix_path, t.name)
            if Tenji::Config.option('retina_images')
              suffix = Tenji::Config.option('retina_suffix_2x')
              name = Pathname.new(t.name).append_to_base(suffix).to_s
              files << Tenji::File::Thumb.new(@site, @base, prefix_path, name)
            end
          end
        end
      end
    end
  end
end
