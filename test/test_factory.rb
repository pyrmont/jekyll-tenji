# frozen_string_literal: true

class TestFactory
  def initialize(site, list: nil, galleries: nil, images: nil, pages: nil, thumbs: nil, covers: nil)
    @config = Tenji::Config

    @site = site
    @base = site.source

    @g_dir = @config.dir(:galleries)
    @t_dir = @config.dir(:thumbs)

    @list = list
    @galleries = galleries
    @images = images
    @pages = pages
    @thumbs = thumbs
    @covers = covers

    @values = { list_page: @list, gallery_pages: @galleries, image_files: @images, image_pages: @pages, thumb_files: @thumbs, cover_files: @covers }
  end

  def make(output, form = :array, input = nil, flatten: false)
    case output
    when :entities, :paths
      req = "#{output}_#{form}"
      res = input || method(req.to_sym).call()

      return res unless flatten
      
      if form == :array
        res.map { |el| squash el }
      elsif form == :hash
        res.transform_values { |el| squash el }
      end
    when :list_page, :gallery_pages, :image_files, :image_pages, :thumb_files, :cover_files
      res = input || entity(output)
      flatten ? squash(res) : res
    end
  end
  
  private def entity(type)
    method(type).call(@values[type])
  end

  private def entities_array()
    [ list_page(@list), gallery_pages(@galleries), image_files(@images), image_pages(@pages), thumb_files(@thumbs), cover_files(@covers) ]
  end
  
  private def entities_hash()
    { list: list_page(@list), galleries: gallery_pages(@galleries), images: image_files(@images), pages: image_pages(@pages), thumbs: thumb_files(@thumbs), covers: cover_files(@covers) } 
  end

  private def paths_array()
    [ list_path(@list), gallery_paths(@galleries), image_paths(@images), page_paths(@pages), Hash.new, Hash.new ]
  end

  private def list_page(list)
    return nil if list.nil?
    Tenji::ListPage.new @site, @base, @g_dir, list.first
  end

  private def list_path(list)
    return nil if list.nil? || list.first.nil?
    Tenji::Path.new(@g_dir) + list.first
  end

  private def gallery_pages(galleries)
    return nil if galleries.nil?
    galleries.reduce(Hash.new) do |memo, filename|
      path = Tenji::Path.new filename
      dirname = filename[-1] == '/' ? filename[0...-1] : path.dirname.to_s
      name = filename[-1] == '/' ? nil : path.name
      memo[dirname] = Tenji::GalleryPage.new @site, @base, File.join(@g_dir, dirname), name
      memo
    end
  end

  private def gallery_paths(galleries)
    return nil if galleries.nil?
    galleries.reduce(Hash.new) do |memo, filename|
      path = Tenji::Path.new filename 
      dirname = filename[-1] == '/' ? filename[0...-1] : path.dirname.to_s
      full_path = filename[-1] == '/' ? nil : @config.path(:galleries) + filename
      memo[dirname] = full_path
      memo
    end
  end

  private def image_files(images)
    return nil if images.nil?
    images.reduce(Hash.new { |h,k| h[k] = Array.new }) do |memo, filename|
      path = Tenji::Path.new filename
      dir = File.join(@g_dir, path.parent.to_s)
      memo[path.parent.to_s].push(Tenji::ImageFile.new @site, @base, dir, path.name)
      memo
    end
  end

  private def image_paths(images)
    return nil if images.nil?
    images.reduce(Hash.new { |h,k| h[k] = Array.new }) do |memo, filename|
      path = Tenji::Path.new filename
      memo[path.parent.to_s].push(@config.path(:galleries) + filename)
      memo
    end
  end

  private def image_pages(pages)
    return nil if pages.nil?
    pages.reduce(Hash.new { |h,k| h[k] = Hash.new }) do |memo, filename|
      path = Tenji::Path.new filename
      dir = File.join(@g_dir, path.parent.to_s)
      memo[path.parent.to_s][path.base] = Tenji::ImagePage.new @site, @base, dir, path.name
      memo
    end
  end

  private def page_paths(pages)
    return nil if pages.nil?
    pages.reduce(Hash.new { |h,k| h[k] = Hash.new }) do |memo, filename|
      path = Tenji::Path.new filename
      memo[path.parent.to_s][path.base] = @config.path(:galleries) + filename
      memo
    end
  end

  private def thumb_files(thumbs)
    return nil if thumbs.nil?
    thumbs.reduce(Hash.new { |h,k| h[k] = Hash.new { |i,l| i[l] = Hash.new } }) do |memo, filename|
      size_start = filename.rindex('-') + 1
      size_stop = filename.rindex('.')
      size = filename[size_start...size_stop]
      path = Tenji::Path.new filename
      dir = File.join(@t_dir, path.parent.to_s)
      source_path = Tenji::Path.new(File.join(@g_dir, filename.sub("-#{size}", '')))
      memo[path.parent.to_s][source_path.name][size] = Tenji::ThumbFile.new @site, @base, dir, path.name, source_path.to_s
      memo
    end
  end

  private def cover_files(covers)
    return nil if covers.nil?
    covers.reduce(Hash.new) do |memo, filename|
      path = Tenji::Path.new filename
      dir = File.join(@t_dir, path.parent.to_s)
      memo[path.parent.to_s] = Tenji::ThumbFile.new @site, @base, dir, path.name
      memo
    end
  end
  
  private def squash(obj)
    return obj unless obj.is_a?(Array) || obj.is_a?(Hash)

    to_traverse = Array.new
    result = Array.new

    to_traverse.push obj
    
    to_traverse.each do |el|
      if el.is_a? Array
        to_traverse.concat el
      elsif el.is_a? Hash
        to_traverse.concat el.values
      elsif !el.nil?
        result.push el
      end
    end

    result
  end
end
