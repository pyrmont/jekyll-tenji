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
      
      @galleries = init_galleries(site_dir + input_dir)
      @list = Tenji::List.new(site_dir + input_dir, @galleries['listed'])

      write_thumbnails site, @galleries['all']
      generate_galleries site, @galleries['all'], output_dir
      generate_list site, @list, output_dir
      
      Jekyll::Hooks.register :site, :pre_render, &method(:add_tenji)
    end

    private def add_tenji(site, payload)
      tenji = { 'all_galleries' => @galleries['all'],
                'galleries' => @galleries['listed'],
                'hidden_galleries' => @galleries['hidden'] }
      payload['tenji'] = tenji
    end

    private def generate_galleries(site, galleries, dir)
      site.is_a! Jekyll::Site
      galleries.is_a! Array
      dir.is_a! Pathname

      base_dir = Pathname.new site.source

      galleries.each do |g|
        gg = Tenji::Generator::Gallery.new g, site, base_dir
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

    private def init_galleries(dir)
      dir.is_a! Pathname

      galleries = dir.subdirectories.map do |s|
                    Tenji::Gallery.new s
                  end
      galleries.sort!

      res = { 'all' => Array.new, 'listed' => Array.new, 'hidden' => Array.new }
      galleries.each do |g|
        res['all'].push g
        (g.hidden?) ? res['hidden'].push(g) : res['listed'].push(g)
      end
      res
    end

    private def write_thumbnails(site, galleries)
      site.is_a! Jekyll::Site
      galleries.is_a! Array

      base_dir = Pathname.new site.source
      config = Tenji::Config

      galleries.each do |g|
        input_dir = base_dir + config.dir(:galleries) + g.dirnames['input']
        output_dir = base_dir + config.dir(:thumbs) + g.dirnames['output']
        output_dir.mkpath unless output_dir.exist?
        
        source_file = input_dir + g.cover.source.name
        Tenji::Writer::Thumb.write g.cover, source_file, output_dir

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
