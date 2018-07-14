require 'test_helper'

class TenjiPageListTest < Minitest::Test
  context "Tenji::Page::List" do
    setup do
      Tenji::Config.configure
      dir = Pathname.new 'test/data/gallery1'
      @list = Tenji::List.new dir
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @prefix_path = dir.to_s
      @name = 'index.html'
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Page::List object" do
        obj = Tenji::Page::List.new @list, @site, @base, @prefix_path, @name
        assert_equal 'Tenji::Page::List', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pl = Tenji::Page::List
        assert_raises(Tenji::TypeError) { pl.new nil, @site, @base, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pl.new @list,  nil, @base, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, nil, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, @base, nil, @name }
        assert_raises(Tenji::TypeError) { pl.new @list, @site, @base, @prefix_path, nil }
      end
    end

    context "has a method #destination that" do
      setup do
        @fake_path = 'not/a/real/path/_albums/'
        @obj = Tenji::Page::List.new @list, @site, @base, @fake_path, @name
      end

      should "return a modified path" do
        local_path = 'tmp/not/a/real/path/albums/index.html'
        dest_expected = Pathname.new(local_path).expand_path.to_s
        dest_actual = @obj.destination @site.dest
        assert_equal dest_expected, dest_actual
      end

      should "raise an error for an invalid argument" do
        assert_raises(Tenji::TypeError) { @obj.destination nil }
      end
    end
  end
end
