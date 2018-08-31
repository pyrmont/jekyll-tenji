require 'test_helper'

describe Tenji::ThumbFile do
  before do
    @config = Tenji::Config
    @config.configure({ 'galleries_dir' => '_albums' })
    @site = TestSite.site source: 'test/data/', dest: 'tmp'
    @base = @site.source
    @obj = Tenji::ThumbFile.new @site, @base, '_thumbs/gallery', 'foo.jpg', '_albums/gallery/bar.jpg'
  end

  after do
    @config.reset
  end
    
  describe "#initialize" do
    it "instantiates a Tenji::ThumbFile object with no source" do
      obj = Tenji::ThumbFile.new @site, @base, '_thumbs/gallery', 'foo.jpg'
      assert_equal Tenji::ThumbFile, obj.class
      assert_equal 'foo.jpg', obj.name
      assert_equal 'albums/gallery/thumbs', obj.instance_variable_get(:@dir)
      assert_equal File.join(@base, '_thumbs/gallery/', 'foo.jpg'), obj.path
      assert_nil obj.source_path
    end 

    it "instantiates a Tenji::ThumbFile object with a source" do
      obj = Tenji::ThumbFile.new @site, @base, '_thumbs/gallery', 'foo.jpg', '_albums/gallery/bar.jpg'
      assert_equal Tenji::ThumbFile, obj.class
      assert_equal 'foo.jpg', obj.name
      assert_equal 'albums/gallery/thumbs', obj.instance_variable_get(:@dir)
      assert_equal File.join(@base, '_thumbs/gallery/', 'foo.jpg'), obj.path
      assert_equal File.join(@base, '_albums/gallery/', 'bar.jpg'), obj.source_path
    end 
  end

  describe "#write" do
    before do
      Jekyll::StaticFile.alias_method :orig_write, :write
      Jekyll::StaticFile.class_eval { def write(dest) puts destination(dest) end }
    end

    after do
      Jekyll::StaticFile.alias_method :write, :orig_write
      Jekyll::StaticFile.remove_method :orig_write
    end

    it "writes the file to the destination directory" do
      @obj.write ''
    end
  end
end
