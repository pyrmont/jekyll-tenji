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
      assert_nil obj.position
    end
    
    it "instantiates a Tenji::ImageFile object for a file that doesn't exist" do
      obj = Tenji::ImageFile.new @site, @base, '_albums/gallery', 'foo.jpg'
      assert_equal Tenji::ImageFile, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal 'albums/gallery', obj.instance_variable_get(:@dir)
      assert_equal 'foo.jpg', obj.name
      assert_equal File.join(@base, '_albums/gallery', 'foo.jpg'), obj.path
      assert_nil obj.position
    end
  end

  describe "#<=>" do
    before do
      factory = TestFactory.new @site, images: [ 'gallery/00-image.jpg', 'gallery/01-image.jpg', 'gallery/02-image.jpg' ]
      @comps = factory.make :image_files, flatten: true
    end

    it "compares itself with Tenji::ImageFiles with no EXIF data" do
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]
    end
  end

  describe "#gallery=" do
    it "assigns the parameter" do
      gallery = Object.new
      @obj.gallery = gallery
      assert_equal gallery, @obj.data['gallery']
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
end