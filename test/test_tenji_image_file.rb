require 'test_helper'

describe Tenji::ImageFile do
  before do
    @config = Tenji::Config
    @config.configure({ 'galleries_dir' => '_albums' })
    @site = TestSite.site source: 'test/data/', dest: 'tmp'
    @base = @site.source
    @obj = Tenji::ImageFile.new @site, @base, '_albums/gallery', '01-image.jpg'
  end

  after do
    @config.reset
  end
    
  describe "#initialize" do
    it "instantiates a Tenji::ImageFile object for a file that exists" do
      obj = Tenji::ImageFile.new @site, @base, '_albums/gallery', '01-castle.jpg'
      assert_equal Tenji::ImageFile, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal 'albums/gallery', obj.instance_variable_get(:@dir)
      assert_equal '01-castle.jpg', obj.name
      assert_equal File.join(@base, '_albums/gallery', '01-castle.jpg'), obj.path
      assert_equal File.join('albums/gallery', '01-castle.jpg'), obj.relative_path
      assert_equal '.jpg', obj.extname
      assert_equal Hash, obj.data.class
      assert_nil obj.position
    end
    
    it "instantiates a Tenji::ImageFile object for a file that doesn't exist" do
      obj = Tenji::ImageFile.new @site, @base, '_albums/gallery', 'foo.jpg'
      assert_equal Tenji::ImageFile, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal 'albums/gallery', obj.instance_variable_get(:@dir)
      assert_equal 'foo.jpg', obj.name
      assert_equal File.join(@base, '_albums/gallery', 'foo.jpg'), obj.path
      assert_equal File.join('albums/gallery', 'foo.jpg'), obj.relative_path
      assert_equal '.jpg', obj.extname
      assert_equal Hash.new, obj.data
      assert_nil obj.position
    end
  end

  describe "#<=>" do
    before do
      factory = TestFactory.new @site, images: [ 'gallery/00-image.jpg', 'gallery/01-image.jpg', 'gallery/02-image.jpg' ]
      @comps = factory.make :image_files, flatten: true
    end

    it "compares itself with Tenji::ImageFile objects with no EXIF data" do
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]

      @obj.instance_variable_get(:@data).update({ 'exif' => { 'date_time' => Date.new(1970, 1, 1).to_time } })

      assert_equal -1, @obj <=> @comps[0]
      assert_equal -1, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'asc', 'time' => 'ignore' }, 'gallery'

      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2] 
    end
    
    it "compares itself with Tenji::ImageFile objects with EXIF data" do
      @comps[0].instance_variable_get(:@data).update({ 'exif' => { 'date_time' => Date.new(1870, 1, 1).to_time } })
      @comps[1].instance_variable_get(:@data).update({ 'exif' => { 'date_time' => Date.new(1970, 1, 1).to_time } })
      @comps[2].instance_variable_get(:@data).update({ 'exif' => { 'date_time' => Date.new(2070, 1, 1).to_time } })
      
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 1, @obj <=> @comps[1]
      assert_equal 1, @obj <=> @comps[2] 
      
      @obj.instance_variable_get(:@data).update({ 'exif' => { 'date_time' => Date.new(1970, 1, 1).to_time } })
       
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'asc', 'time' => 'ignore' }, 'gallery'
      
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]
      
      @config.set 'sort', { 'name' => 'desc', 'time' => 'ignore' }, 'gallery'

      assert_equal -1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal 1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'asc', 'time' => 'asc' }, 'gallery'

      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]
    end
  end

  describe "#downloadable?" do
    before do
      @data = @obj.instance_variable_get(:@data)
      @data['page'] = Struct.new(:data).new(Hash.new)
    end

    it "returns false if the metadata for the image specifies false" do
      @data['page'].data['downloadable'] = false
      refute @obj.downloadable?
    end

    it "returns true if the images in the given gallery can be downloaded" do
      @config.set 'downloadable', true, 'gallery'
      assert @obj.downloadable?
    end

    it "returns false if the images in the given gallery cannot be downloaded" do
      @config.set 'downloadable', false, 'gallery'
      refute @obj.downloadable?
    end

    it "returns the default vslue if the image can be downloaded" do
      assert @obj.downloadable?
    end
  end

  describe "#gallery=" do
    it "assigns the parameter" do
      gallery = Object.new
      @obj.gallery = gallery
      assert_equal gallery, @obj.data['gallery']
    end
  end

  describe "#image_next" do
    before do
      @obj.instance_variable_set(:@position, 1)
      @data = @obj.instance_variable_get(:@data)
      @expected = Object.new
    end

    it "returns the object that is next in the gallery" do
      @data['gallery'] = Struct.new(:data).new({ 'images' => [ nil, nil, @expected ] })
      assert_equal @expected, @obj.image_next
    end

    it "returns nil if there is no image next in the gallery" do
      @data['gallery'] = Struct.new(:data).new({ 'images' => [ nil, nil ] })
      assert_nil @obj.image_next
    end
  end

  describe "#image_prev" do
    before do
      @obj.instance_variable_set(:@position, 1)
      @data = @obj.instance_variable_get(:@data)
      @expected = Object.new
    end

    it "returns the object that is previous in the gallery" do
      @data['gallery'] = Struct.new(:data).new({ 'images' => [ @expected, nil, nil] })
      assert_equal @expected, @obj.image_prev
    end

    it "returns nil if there is no image previous in the gallery" do
      @obj.instance_variable_set(:@position, 0)
      @data['gallery'] = Struct.new(:data).new({ 'images' => [ nil, nil ] })
      assert_nil @obj.image_next
    end
  end

  describe "#page=" do
    it "assigns the parameter" do
      page = Object.new
      @obj.page = page
      assert_equal page, @obj.data['page']
    end
  end

  describe "#sizes=" do
    it "assigns the parameter" do
      sizes = Object.new
      @obj.sizes = sizes
      assert_equal sizes, @obj.data['sizes']
    end
  end

  describe "#to_liquid" do
    before do
      @obj.instance_variable_set(:@position, 1)
      @data = @obj.instance_variable_get(:@data)
      @data['page'] = Struct.new(:data).new(Hash.new)
      @data['gallery'] = Struct.new(:data).new({ 'images' => [ nil, nil, nil ] })
    end

    it "returns a hash with certain keys set" do
      res = @obj.to_liquid
      assert res.key?('downloadable')
      assert res.key?('next')
      assert res.key?('prev')
      assert res.key?('url')
    end
  end
end
