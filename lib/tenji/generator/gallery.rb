# frozen_string_literal: true

module Tenji
  class Generator < Jekyll::Generator
    class Gallery
      using Tenji::Refinements

      attr_reader :gallery, :site, :base, :prefix_path

      def initialize(gallery, site, base_dir, gallery_dir)
        gallery.is_a! Tenji::Gallery
        site.is_a! Jekyll::Site
        base_dir.is_a! Pathname
        gallery_dir.is_a! Pathname

        @gallery = gallery
        @site = site
        @base = base_dir.to_s
        @dir = gallery_dir.to_s
      end

      def generate_images(files)
        files.is_a! Array
        return unless @gallery.metadata['quality'] == 'original'
        @gallery.images.each do |i|
          params = [ @site, @base, @dir, i.name, @gallery.dirname ]
          files << Tenji::File::Image.new(*params)
        end
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        params = [ @gallery, @site, @base, @dir, name, @gallery.dirname ]
        pages << Tenji::Page::Gallery.new(*params)
      end

      def generate_individual_pages(pages)
        pages.is_a! Array
        return unless @gallery.metadata['individual_pages']
        @gallery.images.each do |i|
          params = [ i, @site, @base, @dir, i.name, @gallery.dirname ]
          pages << Tenji::Page::Image.new(*params)
        end
      end

      def generate_thumbs(files)
        files.is_a! Array

        factors = 1..Tenji::Config.option('scale_max')

        dir = ::File.join(@dir, Tenji::Config.dir('thumbs', output: true))
        @gallery.images.each do |i|
          i.thumbs.each_value do |t|
            pos = t.name.rindex '.'
            factors.each do |f|
              fix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
              name = t.name.infix(pos, fix)
              params = [ @site, @base, dir, name, @gallery.dirname ]
              files << Tenji::File::Thumb.new(*params)
            end
          end
        end
      end
    end
  end
end
