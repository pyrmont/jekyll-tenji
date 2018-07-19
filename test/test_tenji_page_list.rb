require 'test_helper'

class TenjiPageListTest < Minitest::Test
  context "Tenji::Page::List" do
    setup do
      Tenji::Config.configure
      galleries_dir = Pathname.new 'test/data/_albums'
      @list = Tenji::List.new galleries_dir
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @dir = galleries_dir.to_s
      @name = 'index.html'
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Page::List object" do
        obj = Tenji::Page::List.new @list, @site, @base, @dir, @name
        assert_equal 'Tenji::Page::List', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pl = Tenji::Page::List
        assert_raises(Tenji::TypeError) { pl.new nil, @site, @base, @dir, @name }
        assert_raises(Tenji::TypeError) { pl.new @list,  nil, @base, @dir, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, nil, @dir, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, @base, nil, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, @base, @dir, nil }
      end
    end

    context "has a method #path that" do
      setup do
        Tenji::Config.configure
      end

      teardown do
        Tenji::Config.reset
      end

      should "return a directory path" do
        obj = Tenji::Page::List.new @list, @site, @base, @dir, @name
        assert_equal '_albums/index.html', obj.path
      end
    end
  end
end
