# frozen_string_literal: true

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    attr_accessor :base, :config, :galleries, :post, :pre, :site, :writer

    def initialize(options = {})
      @site = nil
      @base = (options) ? options['source'] : ''
      @config = Tenji::Config
      @pre = Tenji::Queue.new
      @post = Tenji::Queue.new
      @galleries = { 'all' => Array.new, 
                     'hidden' => Array.new, 
                     'listed' => Array.new }
      @writer = Tenji::Writer.new
    end

    def generate(site)
      @site = site

      read
      make
      sort
      reference
      write
      assign
    end

    def assign()
      assign_list_page
      assign_gallery_pages
      assign_image_files
      assign_image_pages
      assign_thumb_files
      assign_cover_files
    end

    def make()
      make_list_page
      make_gallery_pages
      make_image_files
      make_image_pages
      make_thumb_files
      make_cover_files
    end

    def read()
      dir = config.dir(:galleries)

      add_file(dir.index || nil)

      dir.subdirectories.each do |s|
        add_file nil, s.name unless s.index
        s.files.each do |f|
          add_file f, s.name
        end
      end
    end

    def reference()
      add_references_to_list
      add_references_to_galleries
      add_references_to_images
      add_references_to_covers
    end

    def sort()
      sort_galleries
      sort_images
    end

    def write()
      write_thumb_files
      write_cover_files
    end

    private def add_file(file, dirname = nil)
      if dirname.nil?
        pre.list_page = file 
      elsif file.nil? || file.index?
        pre.gallery_pages[dirname] = file
      elsif file.page?
        pre.image_pages[dirname][file.base] = file
      elsif file.image?
        pre.image_files[dirname].push file
      end
    end

    private def add_references_to_covers()
      post.cover_files.each do |dirname, cover|
        dir = (config.dir(:galleries) + dirname).to_s
        name = config.cover(dirname) || post.image_files[dirname].first.name
        cover.source_path = File.join(base, dir, name)
      end
    end

    private def add_references_to_galleries()
      post.gallery_pages.each do |dirname, page|
        page.cover = post.cover_files[dirname]
        page.images = post.image_files[dirname]
      end
    end

    private def add_references_to_images()
      post.image_files.each do |dirname, files|
        files.each do |file|
          file_base = File.basename(file.name, '.*')
          file.gallery = post.gallery_pages[dirname]
          file.page = post.image_pages[dirname][file_base]
          file.sizes = post.thumb_files[dirname][file.name]
          page = post.image_pages[dirname][file_base]
          page.image = file unless page.nil?
        end
      end
    end

    private def add_references_to_list()
      post.list_page.galleries = galleries['listed']
    end

    private def assign_cover_files()
      post.cover_files.each do |dirname, file|
        site.static_files << file
      end
    end

    private def assign_gallery_pages()
      post.gallery_pages.each do |dirname, page|
        site.pages << page
      end
    end

    private def assign_image_files()
      post.image_files.each do |dirname, files|
        files.each do |file|
          site.static_files << file
        end
      end
    end

    private def assign_image_pages()
      post.image_pages.each do |dirname, pages|
        pages.each do |basename, page|
          site.pages << page
        end
      end
    end

    private def assign_list_page()
      site.pages << post.list_page
    end

    private def assign_thumb_files()
      post.thumb_files.each do |dirname, thumbs|
        thumbs.each do |basename, sizes|
          sizes.each do |size, file|
            site.static_files << file
          end
        end
      end
    end

    private def make_cover_files()
      pre.image_files.each do |dirname, files|
        next if files.empty?
        dir = (@config.dir(:thumbs) + dirname).to_s
        cover = Tenji::ThumbFile.new site, base, dir, 'cover.jpg'
        post.cover_files[dirname] = cover
      end
    end

    private def make_gallery_pages()
      pre.gallery_pages.each do |dirname, file|
        dir = (config.dir(:galleries) + dirname).to_s
        name = file&.name
        gallery = Tenji::GalleryPage.new(site, base, dir, name)        
        post.gallery_pages[dirname] = gallery
        galleries['all'].push gallery
      end
    end

    private def make_image_files()
      pre.image_files.each do |dirname, files|
        dir = (config.dir(:galleries) + dirname).to_s
        files.each do |file|
          image = Tenji::ImageFile.new(site, base, dir, file.name)
          post.image_files[dirname].push image
        end
      end
    end

    private def make_image_pages()
      pre.image_pages.each do |dirname, files|
        dir = (config.dir(:galleries) + dirname).to_s
        files.each do |basename, file|
          image = Tenji::ImagePage.new(site, base, dir, file.name)
          post.image_pages[dirname][basename] = image
        end
      end
    end

    private def make_list_page()
      dir = config.dir(:galleries).to_s
      file = pre.list_page
      post.list_page = Tenji::ListPage.new(site, base, dir, file&.name)
    end

    private def make_thumb_files()
      pre.image_files.each do |dirname, files|
        dir = (config.dir(:thumbs) + dirname).to_s

        files.each do |file|
          config.thumb_sizes(dirname).each do |size, options|
            name = file.name.append_to_base("-#{size}")
            thumb = Tenji::ThumbFile.new(site, base, dir, name, file.to_s)
            post.thumb_files[dirname][file.name][size] = thumb
          end
        end
      end
    end 

    private def sort_galleries()
      galleries['hidden'] = Array.new
      galleries['listed'] = Array.new
      
      galleries['all'].sort!
      
      galleries['all'].each do |gallery|
        type = config.hidden?(gallery.gallery_name) ? 'hidden' : 'listed'
        galleries[type].push gallery
      end
    end
    
    private def sort_images()
      post.image_files.each do |dirname, files|
        files.sort!
        files.each.with_index do |file,index| 
          file.position = index
        end
      end
    end

    private def write_cover_files()
      post.cover_files.each do |dirname, cover|
        writer.write_thumb cover.source_path,
                           cover.path, 
                           config.constraints(:cover), 
                           config.resize_function(:cover),
                           config.scale_factors
      end
    end

    private def write_thumb_files()
      post.thumb_files.each do |dirname, thumbs|
        thumbs.each do |basename, sizes|
          sizes.each do |size, thumb|
            writer.write_thumb thumb.source_path,
                               thumb.path, 
                               config.constraints(size, dirname), 
                               config.resize_function(size, dirname),
                               config.scale_factors
          end
        end
      end
    end
  end
end
