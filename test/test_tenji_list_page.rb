require 'test_helper'

describe Tenji::ListPage do
  before do
    @config = Tenji::Config
    @config.configure({ 'galleries_dir' => '_albums' })
    @site = TestSite.site source: 'test/data/', dest: 'tmp'
    @base = @site.source
    @obj = Tenji::ListPage.new @site, @base, '_albums', 'index.md'
  end

  after do
    @config.reset
  end
    
  describe "#initialize" do
    it "instantiates a Tenji::ListPage object for a file that doesn't exist" do
      obj = Tenji::ListPage.new @site, @base, '_albums/', 'index.md'
      assert_equal Tenji::ListPage, obj.class
      assert_equal File.join(@base, '_albums', 'index.md'), obj.path
      assert_equal 'index', obj.basename
      assert_equal '.md', obj.ext
      assert_equal '/albums/', obj.dir
      assert_nil obj.content
    end 
  end
end
