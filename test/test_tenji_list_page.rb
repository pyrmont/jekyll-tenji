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

  describe "#galleries=" do
    it "assigns the parameter" do
      galleries = Object.new
      @obj.galleries = galleries
      assert_equal galleries, @obj.data['galleries']
    end
  end

  describe "#items" do
    it "gets the pageable items" do
      assert_nil @obj.items

      galleries = Object.new
      @obj.instance_variable_get(:@data)['galleries'] = galleries

      assert_equal galleries, @obj.items
    end
  end
  
  describe "#items=" do
    it "sets the pageable items" do
      assert_nil @obj.instance_variable_get(:@data)['galleries']

      galleries = Object.new
      @obj.items = galleries

      assert_equal galleries, @obj.instance_variable_get(:@data)['galleries']
    end
  end
  
  describe "#write" do
    it "uses the method defined on Tenji::Pageable::Page" do
      method = @obj.method(:write)
      assert_equal Tenji::Pageable::Page, method.owner
    end

    it "uses the method defined on Jekyll::Convertible" do
      @config.set [ 'galleries_per_page' ], false
      @obj = Tenji::ListPage.new @site, @base, '_albums', nil
      
      method = @obj.method(:write)
      assert_equal Jekyll::Convertible, method.owner
    end

    describe "with a modified ListPage class" do
      before do
        Tenji::ListPage.class_eval { def write(dest) puts destination(dest) end }

        @config.set [ 'galleries_per_page' ], 1
        factory = TestFactory.new @site, galleries: [ 'gallery1/', 'gallery2/', 'gallery3/' ]
        
        @obj = Tenji::ListPage.new @site, @base, '_albums', nil
        @obj.galleries = factory.make :gallery_pages, flatten: true  
      end

      after do
        Tenji::ListPage.remove_method :write
      end

      it "outputs the paths to which it will write its pages" do
        output, errors = capture_io { @obj.write '' } 
        paths = output.split("\n")
        assert_equal File.join(@site.dest, 'albums/index.html'), paths[0]
        assert_equal File.join(@site.dest, 'albums/2/index.html'), paths[1]
        assert_equal File.join(@site.dest, 'albums/3/index.html'), paths[2]
      end
    end
  end
end
