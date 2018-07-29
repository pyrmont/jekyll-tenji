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
        params = [ @gallery, 'images', @gallery.metadata['paginate'],
                   @gallery.url + 'page-#num/' ]
        gallery = Tenji::Paginator.new(*params)
        gallery.pages.each do |g|
          g = paged_metadata(gallery, g)
          output_dirname = paged_dirname(gallery, g)
          params = [ g, @site, @base, output_dirname, name, @input_dirname ]
          pages << Tenji::Page::Gallery.new(*params)
        end
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

        input_dirname = ::File.join(Tenji::Config.dir('thumbs'),
                                    @gallery.dirnames['output'])
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

      private def paged_dirname(gallery, g)
        num = gallery.number g
        if num > 1
          ::File.join(@output_dirname, 'page-' + num.to_s)
        else
          @output_dirname
        end
      end

      private def paged_metadata(gallery, g)
        num = gallery.number g
        metadata = g.metadata.merge(gallery.urls(num))
        g.instance_variable_set(:@metadata, metadata)
        g
      end
    end
  end
end
