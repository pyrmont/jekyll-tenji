# frozen_string_literal: true

module Tenji

  # Tenji's generator for Jekyll
  #
  # Jekyll supports plugins adding generators to the Jekyll build system. A
  # generator can be used to generate objects that will be added to the
  # collections of objects Jekyll processes to build a website.
  #
  # {Tenji::Generator} generates the {Tenji::GalleryPage}, {Tenji::ImagePage}
  # and {Tenji::ListPage} pages that are added to Jekyll via the 
  # `Jekyll::Site#pages` method and the {Tenji::ImageFile} and 
  # {Tenji::ThumbFile} that are added to Jekyll via the 
  # `Jekyll::Site#static_files` method. In addition, {Tenji::Generator}
  # generates the thumbnail images and writes these to disk (if necessary).
  #
  # @since 0.1.0
  # @api public
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    attr_accessor :base, :config, :galleries, :post, :pre, :site, :writer

    # Initialise an object of this class
    #
    # @note The purpose of expressly defining the constructor is to assist with
    #   testing purposes. Jekyll does not pass any options to the constructor.
    #
    # @param options [Hash] options to use to initialise the object
    #
    # @return [Tenji::Generator] the initialised object
    #
    # @since 0.1.0
    # @api public
    def initialize(options = {})
      @site = nil
      @base = options['source'] || ''
      @config = Tenji::Config
      @pre = Tenji::Queue.new
      @post = Tenji::Queue.new
      @galleries = { 'all' => Array.new, 
                     'hidden' => Array.new, 
                     'listed' => Array.new }
      @writer = Tenji::Writer.new
    end

    # Generate Tenji's objects and add them to Jekyll
    #
    # Tenji's generation process consists of six steps: (1) read; (2) make; (3)
    # sort; (4) reference; (5) write; and (6) assign.
    #
    # After these steps are performed, Tenji adds an object to Jekyll's site
    # payload that holds references to the galleries created. This object can
    # be used in Liquid templates by referencing the top-level `tenji` object.
    # See {file:Templating.md} for more information on how to use Tenji with
    # Liquid templates.
    #
    # @param site [Jekyll::Site] an object representing the Jekyll site
    #
    # @since 0.1.0
    # @api public
    def generate(site)
      @site = site
      @config.configure site.config['galleries']

      read
      make
      sort
      reference
      write
      assign

      Jekyll::Hooks.register :site, :pre_render, &method(:update_payload)
    end

    # Assign the objects created by Tenji to the `Jekyll::Site` object
    #
    # Tenji creates two types of objects: (1) pages; and (2) static files. The
    # pages are assigned to the `Jekyll::Site` object using the 
    # `Jekyll::Site#pages` method. The static files are assigned to the 
    # `Jekyll::Site` object using the `Jekyll::Site#static_files` method.
    #
    # Note that it is only at this stage that the {Tenji::ListPage}, the 
    # {Tenji::ImageFile} and {Tenji::ImagePage} objects are discarded if the
    # user has specified that they are not to be output. Although this is not
    # optimal for performance, it simplifies the logic of the earlier steps
    # in the generation process.
    #
    # @since 0.1.0
    # @api private
    def assign()
      assign_list_page
      assign_gallery_pages
      assign_image_files
      assign_image_pages
      assign_thumb_files
      assign_cover_files
    end

    # Make the various objects used by Tenji
    #
    # Tenji uses four classes to represent the various elements in a gallery.
    # {Tenji::ListPage} represents the page listing the galleries,
    # {Tenji::GalleryPage} represents the page listing the images in a gallery,
    # {Tenji::ImagePage} represents the page displaying a single image,
    # {Tenji::ImageFile} represents the graphics file for an image in the
    # gallery and {Tenji::ThumbFile} represents the graphics file for a
    # thumbnail of an image in the gallery.
    #
    # This method goes through each of the file paths in the pre-production 
    # {Tenji::Queue} object, makes the relevant object and then adds each object
    # to the post-production {Tenji::Queue} object.
    #
    # @since 0.1.0
    # @api private
    def make()
      make_list_page
      make_gallery_pages
      make_image_files
      make_image_pages
      make_thumb_files
      make_cover_files
    end

    # Read the directory
    #
    # Tenji creates a pre-production {Tenji::Queue} object of file paths by 
    # looking at the directory structure under the galleries directory.
    #
    # @since 0.1.0
    # @api private
    def read()
      dir = Tenji::Path.new(base) + config.dir(:galleries)

      add_file(dir.index || nil)

      dir.subdirectories.each do |s|
        add_file nil, s.name unless s.index
        s.files.each do |f|
          add_file f, s.name
        end
      end
    end

    # Adds cross references between Tenji objects
    #
    # Although all {Tenji::Processable} objects share relations with other
    # {Tenji::Processable} objects, these relations are not added at the time of
    # instantiation. Rather, Tenji adds the references after all the objects
    # have been created.
    #
    # It should be noted that the references added for the {Tenji::ThumbFile}
    # objects are merely paths to the source image, expressed as a string. The
    # other objects hold references to their related objects.
    #
    # @since 0.1.0
    # @api private
    def reference()
      add_references_to_list
      add_references_to_galleries
      add_references_to_images
      add_references_to_thumbs
      add_references_to_covers
    end

    # Sort the Tenji objects that are in collections
    #
    # The {Tenji::GalleryPage} and {Tenji::ImageFile} objects are in
    # collections held by the {Tenji::ListPage} and {Tenji::GalleryPage}
    # objects respectively. This method sorts the elements within the
    # post-production queue.
    #
    # @since 0.1.0
    # @api private
    def sort()
      sort_galleries
      sort_images
    end

    # Writes the thumbnails to the disk if necessary
    #
    # As part of its build system, Jekyll writes the output files to the 
    # destination directory. By integrating itself within that build system, 
    # Tenji avoids the need to write its output files separately.
    #
    # However, for performance reasons, Tenji does write the thumbnails it
    # generates to the _source_ directory (subject to an exception). Jekyll will
    # then copy these files to the _destination_ directory as normal.
    #
    # The exception is if a file with the same name exists and had a 
    # modification date that is later than the modification date of the source 
    # image. This means two things. First, it avoids the rendering of thumbnails
    # that are the same as those previously created. Second, it allows a user to
    # create their own thumbnails if they prefer.
    #
    # @since 0.1.0
    # @api private
    def write()
      write_thumb_files
      write_cover_files
    end

    # Add a file path to the pre-production queue
    #
    # @param file [Tenji::Path] the file path
    # @param dirname [String] the name of the parent directory
    #
    # @since 0.1.0
    # @api private
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

    # Add cross references for {Tenji::ThumbFile} objects representing cover
    # images
    #
    # @since 0.1.0
    # @api private
    private def add_references_to_covers()
      post.cover_files.each do |dirname, cover|
        dir = (config.path(:galleries) + dirname).to_s
        name = config.cover(dirname) || post.image_files[dirname].first.name
        cover.source_path = File.join(base, dir, name)
      end
    end

    # Add cross references to the {Tenji::GalleryPage} objects representing
    # galleries
    #
    # @since 0.1.0
    # @api private
    private def add_references_to_galleries()
      post.gallery_pages.each do |dirname, page|
        page.cover = post.cover_files[dirname]
        page.images = post.image_files[dirname]
      end
    end

    # Add cross references to the {Tenji::ImageFile} objects representing the
    # gallery images
    #
    # @since 0.1.0
    # @api private
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

    # Add cross references to the {Tenji::ListPage} object representing the
    # listing of galleries
    #
    # @since 0.1.0
    # @api private
    private def add_references_to_list()
      post.list_page.galleries = galleries['listed']
    end

    # Add cross references for {Tenji::ThumbFile} objects representing thumbnail
    # images
    #
    # @since 0.1.0
    # @api private
    private def add_references_to_thumbs()
      post.thumb_files.each do |dirname, listings|
        listings.each do |name,thumbs|
          thumbs.each do |_, thumb|
            dir = (config.path(:galleries) + dirname).to_s
            thumb.source_path = File.join(base, dir, name)
          end
        end
      end
    end

    # Assign the {Tenji::ThumbFile} objects representing cover images to the
    # Jekyll's collection of static files
    #
    # @since 0.1.0
    # @api private
    private def assign_cover_files()
      post.cover_files.each do |dirname, file|
        site.static_files << file
      end
    end

    # Assign the {Tenji::Gallery} objects representing galleries to Jekyll's
    # collection of pages
    #
    #
    # @since 0.1.0
    # @api private
    private def assign_gallery_pages()
      post.gallery_pages.each do |dirname, page|
        site.pages << page
      end
    end

    # Assign the {Tenji::ImageFile} objects representing gallery images to
    # Jekyll's collection of static files
    #
    # @since 0.1.0
    # @api private
    private def assign_image_files()
      post.image_files.each do |dirname, files|
        files.each do |file|
          next unless file.downloadable?
          site.static_files << file
        end
      end
    end

    # Assign the {Tenji::ImagePage} objects representing the single pages for
    # gallery images to Jekyll's collection of pages
    #
    # @since 0.1.0
    # @api private
    private def assign_image_pages()
      post.image_pages.each do |dirname, pages|
        next unless config.single_pages?(dirname)
        pages.each do |basename, page|
          site.pages << page
        end
      end
    end

    # Assign the {Tenji::ListPage} object representing the listing of galleries
    # to Jekyll's collection of pages
    #
    # @since 0.1.0
    # @api private
    private def assign_list_page()
      return unless config.list?
      site.pages << post.list_page
    end

    # Assign the {Tenji::ThumbFile} objects representing image thumbnails to
    # Jekyll's collection of static files
    #
    # @since 0.1.0
    # @api private
    private def assign_thumb_files()
      post.thumb_files.each do |dirname, thumbs|
        thumbs.each do |basename, sizes|
          sizes.each do |size, file|
            site.static_files << file
          end
        end
      end
    end

    # Make a {Tenji::ThumbFile} object for each cover image
    #
    # @since 0.1.0
    # @api private
    private def make_cover_files()
      pre.image_files.each do |dirname, files|
        next if files.empty?
        dir = (config.path(:thumbs) + dirname).to_s
        cover = Tenji::ThumbFile.new site, base, dir, 'cover.jpg'
        post.cover_files[dirname] = cover
      end
    end

    # Make a {Tenji::GalleryPage} object for each gallery
    #
    # @since 0.1.0
    # @api private
    private def make_gallery_pages()
      pre.gallery_pages.each do |dirname, file|
        dir = (config.path(:galleries) + dirname).to_s
        name = file&.name
        gallery = Tenji::GalleryPage.new(site, base, dir, name)        
        post.gallery_pages[dirname] = gallery
        galleries['all'].push gallery
      end
    end

    # Make a {Tenji::ImageFile} object for each image in a gallery
    #
    # @since 0.1.0
    # @api private
    private def make_image_files()
      pre.image_files.each do |dirname, files|
        dir = (config.path(:galleries) + dirname).to_s
        files.each do |file|
          image = Tenji::ImageFile.new(site, base, dir, file.name)
          post.image_files[dirname].push image
        end
      end
    end

    # Make a {Tenji::ImagePage} object for each single image page in a gallery
    #
    # @since 0.1.0
    # @api private
    private def make_image_pages()
      pre.image_files.each do |dirname, files|
        dir = (config.path(:galleries) + dirname).to_s
        files.each do |file|
          actual_page = pre.image_pages[dirname][file.base]
          name = actual_page&.name || file.base + '.html'
          page = Tenji::ImagePage.new(site, base, dir, name)
          post.image_pages[dirname][file.base] = page
        end
      end
    end

    # Make a {Tenji::ListPage} object for the listing of galleries
    #
    # @since 0.1.0
    # @api private
    private def make_list_page()
      dir = config.dir(:galleries)
      file = pre.list_page
      post.list_page = Tenji::ListPage.new(site, base, dir, file&.name)
    end

    # Make a {Tenji::ThumbFile} object for each image thumbnail
    #
    # @since 0.1.0
    # @api private
    private def make_thumb_files()
      pre.image_files.each do |dirname, files|
        dir = (config.path(:thumbs) + dirname).to_s

        files.each do |file|
          config.thumb_sizes(dirname).each do |size, options|
            name = file.name.append_to_base("-#{size}")
            thumb = Tenji::ThumbFile.new(site, base, dir, name)
            post.thumb_files[dirname][file.name][size] = thumb
          end
        end
      end
    end 

    # Sort the {Tenji::GalleryPage} objects
    #
    # @since 0.1.0
    # @api private
    private def sort_galleries()
      galleries['hidden'] = Array.new
      galleries['listed'] = Array.new
      
      galleries['all'].sort!
      
      galleries['all'].each do |gallery|
        type = config.hidden?(gallery.gallery_name) ? 'hidden' : 'listed'
        galleries[type].push gallery
      end
    end
    
    # Sort the {Tenji::ImageFile} objects
    #
    # @since 0.1.0
    # @api private
    private def sort_images()
      post.image_files.each do |dirname, files|
        files.sort!
        files.each.with_index do |file,index| 
          file.position = index
        end
      end
    end

    # Add the `tenji` object to the `Jekyll::Site` payload
    #
    # @param site [Jekyll::Site] the Jekyll site object
    # @param payload [Hash] the payload
    #
    # @since 0.1.0
    # @api private
    private def update_payload(site, payload)
      tenji = { 'all_galleries' => galleries['all'],
                'galleries' => galleries['listed'],
                'hidden_galleries' => galleries['hidden'] }
      payload['tenji'] = tenji
    end

    # Write the cover files to disk (if necessary)
    #
    # @since 0.1.0
    # @api private
    private def write_cover_files()
      post.cover_files.each do |dirname, cover|
        config.scale_factors.each do |f|
          output_path = cover.path.append_to_base(config.scale_suffix(f))
          constraints = config.constraints(:cover).transform_values { |v| v * f }
          writer.write_thumb cover.source_path,
                             output_path,
                             constraints,
                             config.resize_function(:cover)
        end
      end
    end

    # Write the thumbnail images to disk (if necessary)
    #
    # @since 0.1.0
    # @api private
    private def write_thumb_files()
      post.thumb_files.each do |dirname, thumbs|
        thumbs.each do |basename, sizes|
          sizes.each do |size, thumb|
            config.scale_factors.each do |f|
              output_path = thumb.path.append_to_base(config.scale_suffix(f))
              constraints = config.constraints(size, dirname).transform_values { |v| v * f }
              writer.write_thumb thumb.source_path,
                                 output_path,
                                 constraints,
                                 config.resize_function(size, dirname)
            end
          end
        end
      end
    end
  end
end
