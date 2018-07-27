require 'test_helper'

class TenjiGeneratorListTest < Minitest::Test
  context "Tenji::Generator::List" do
    setup do
      Tenji::Config.configure
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      dir = Pathname.new 'test/data/gallery2'
      @list = Tenji::List.new dir, AnyType.new
    end

    teardown do
      Tenji::Config.reset
      @site = nil
    end

    context "has a method #initialize that" do
      setup do
        @base = Pathname.new @site.source
        @prefix_path = Pathname.new ''
      end

      should "initilaize a Generator::List object" do
        obj = Tenji::Generator::List.new @list, @site, @base, @prefix_path
        assert_equal Tenji::Generator::List, obj.class
      end

      should "raise an error if the arguments are invalid" do
        gl = Tenji::Generator::List
        assert_raises(Tenji::TypeError) { gl.new nil, @site, @base, @prefix_path }
        assert_raises(Tenji::TypeError) { gl.new @list, nil, @base, @prefix_path }
        assert_raises(Tenji::TypeError) { gl.new @list, @site, nil, @prefix_path }
        assert_raises(Tenji::TypeError) { gl.new @list, @site, @base, nil }
      end
    end

    context "has a method #generate_index that" do
      setup do
        base = Pathname.new @site.source
        prefix_path = Pathname.new ''
        @obj = Tenji::Generator::List.new @list, @site, base, prefix_path
      end

      should "add to an array of Page objects" do
        pages = Array.new
        @obj.generate_index pages
        assert_equal [ Tenji::Page::List ], pages.map { |p| p.class }.uniq
      end

      should "raise an error with invalid arguments" do
        assert_raises(Tenji::TypeError) { @obj.generate_index nil }
      end
    end
  end
end
