# frozen_string_literal: true

module Tenji
  class Generator < Jekyll::Generator
    class Gallery
      using Tenji::Refinements

      def initialize(gallery, site, base_dir)
        gallery.is_a! Tenji::Gallery
        site.is_a! Jekyll::Site
        base_dir.is_a! Pathname

        @gallery = gallery
        @site = site
        @base = base_dir.to_s
        @input_dirname = init_dirname(gallery.dirnames['input'], output: false)
        @output_dirname = init_dirname(gallery.dirnames['output'], output: true)
      end

      def generate_images(files)
        files.is_a! Array
        return unless @gallery.metadata['quality'] == 'original'
        @gallery.images.each do |i|
          params = [ @site, @base, @output_dirname, i.name, @input_dirname ]
          files << Tenji::File::Image.new(*params)
        end
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        params = [ @gallery, @site, @base, @output_dirname, name, @input_dirname ]
        pages << Tenji::Page::Gallery.new(*params)
      end

      def generate_individual_pages(pages)
        pages.is_a! Array
        return unless @gallery.metadata['individual_pages']
        @gallery.images.each do |i|
          params = [ i, @site, @base, @output_dirname, i.name, @input_dirname ]
          pages << Tenji::Page::Image.new(*params)
        end
      end

      def generate_thumbs(files)
        files.is_a! Array

        factors = 1..Tenji::Config.option('scale_max')

        input_dirname = ::File.join(Tenji::Config.dir('thumbs'), @gallery.dirnames['output'])
        output_dirname = ::File.join(@output_dirname, 
                                     Tenji::Config.dir('thumbs', output: true))
        @gallery.images.each do |i|
          i.thumbs.each_value do |t|
            pos = t.name.rindex '.'
            factors.each do |f|
              fix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
              name = t.name.infix(pos, fix)
              params = [ @site, @base, output_dirname, name, input_dirname ]
              files << Tenji::File::Thumb.new(*params)
            end
          end
        end
      end

      private def init_dirname(gallery_name, output: false)
        galleries_dirname = Tenji::Config.dir('galleries', output: output)
        ::File.join(galleries_dirname, gallery_name)
      end
    end
  end
end
