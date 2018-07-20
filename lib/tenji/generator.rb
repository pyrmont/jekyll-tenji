# frozen_string_literal: true

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    safe true

    def generate(site)
      site.is_a! Jekyll::Site
 
      Tenji::Config.configure(site.config['galleries'] || Hash.new)

      site_dir = Pathname.new site.source
      input_dir = Pathname.new Tenji::Config.dir(:galleries)
      output_dir = Pathname.new Tenji::Config.dir(:galleries, output: true)
      
      list = Tenji::List.new(site_dir + input_dir)

      write_thumbnails site, list.galleries
      generate_list site, list, output_dir
      generate_galleries site, list.galleries, output_dir
      
      add_tenji = Proc.new { |site,payload| payload['tenji'] = list }
      Jekyll::Hooks.register :site, :pre_render, &add_tenji
    end

    private def generate_galleries(site, galleries, dir)
      site.is_a! Jekyll::Site
      galleries.is_a! Array
      dir.is_a! Pathname

      base_dir = Pathname.new site.source

      galleries.each do |g|
        gallery_dir = dir + g.dirname
        gg = Tenji::Generator::Gallery.new g, site, base_dir, gallery_dir
        gg.generate_index site.pages
        gg.generate_images site.static_files
        gg.generate_thumbs site.static_files
        gg.generate_individual_pages site.pages
      end
    end

    private def generate_list(site, list, dir)
      site.is_a! Jekyll::Site
      list.is_a! Tenji::List
      dir.is_a! Pathname

      base_dir = Pathname.new site.source

      gl = Tenji::Generator::List.new list, site, base_dir, dir
      gl.generate_index site.pages
    end

    private def write_thumbnails(site, galleries)
      site.is_a! Jekyll::Site
      galleries.is_a! Array

      base_dir = Pathname.new site.source

      galleries.each do |g|
        input_dir = base_dir + Tenji::Config.dir(:galleries) + g.dirname
        output_dir = base_dir + Tenji::Config.dir(:thumbs) + g.dirname
        output_dir.mkpath unless output_dir.exist?
        g.images.each do |i|
          source_file = input_dir + i.name
          i.thumbs.each_value do |t|
            Tenji::Writer::Thumb.write t, source_file, output_dir
          end
        end
      end
    end
  end
end
