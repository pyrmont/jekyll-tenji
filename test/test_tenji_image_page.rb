require 'test_helper'

describe Tenji::ImagePage do
  before do
    @config = Tenji::Config
    @config.configure({ 'galleries_dir' => '_albums' })
    @site = TestSite.site source: 'test/data/', dest: 'tmp'
    @base = @site.source
    @obj = Tenji::ImagePage.new @site, @base, '_albums/gallery', '01-castle.md'
  end

  after do
    @config.reset
  end
    
  describe "#initialize" do
    it "instantiates a Tenji::ImagePage object for a file that exists" do
      obj = Tenji::ImagePage.new @site, @base, '_albums/gallery', '01-castle.md'
      assert_equal Tenji::ImagePage, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal File.join(@base, '_albums/gallery', '01-castle.md'), obj.path
      assert_equal '01-castle', obj.basename
      assert_equal '.md', obj.ext
      assert_equal '/albums/gallery/', obj.dir
      assert_equal "This is an image.\n", obj.content
    end  

    it "instantiates a Tenji::ImagePage object for a file that doesn't exist" do
      obj = Tenji::ImagePage.new @site, @base, '_albums/gallery', 'foo.md'
      assert_equal Tenji::ImagePage, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal File.join(@base, '_albums/gallery', 'foo.md'), obj.path
      assert_equal 'foo', obj.basename
      assert_equal '.md', obj.ext
      assert_equal '/albums/gallery/', obj.dir
      assert_nil obj.content
    end  
  end  

  describe "#image=" do
    it "assigns the parameter" do
      image = Object.new
      @obj.image = image
      assert_equal image, @obj.data['image']
    end
  end

  describe "#to_liquid" do
    before do
      @data = @obj.instance_variable_get(:@data)
      @data['image'] = Struct.new(:image_next, :image_prev).new(nil, nil)
    end

    it "returns a hash with certain keys set" do
      res = @obj.to_liquid
      assert res.key?('layout')
      assert res.key?('next')
      assert res.key?('prev')
    end
  end
end
