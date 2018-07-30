require 'test_helper'

class TenjiPaginatorTest < Minitest::Test
  context "Tenji::Paginator" do
    setup do
      Tenji::Config.configure
      dir = Pathname.new 'test/data/gallery1/'
      source = Tenji::Gallery.new dir
      names = { 'items' => '@images', 'data' => '@metadata' }
      page_template = 'page-#num/'
      @p1 = Tenji::Paginator.new source, names, source.metadata['paginate'], source.url, page_template
      dir = Pathname.new 'test/data/gallery4/'
      source = Tenji::Gallery.new dir
      @p2 = Tenji::Paginator.new source, names, source.metadata['paginate'], source.url, page_template
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialize the Paginator object with a Gallery source" do
        assert_equal Tenji::Paginator, @p1.class
        assert_equal Tenji::Paginator, @p2.class
      end
    end

    context "has a method #number that" do
      should "return the number of the page" do
        obj = @p2.page 1
        assert_equal 1, @p2.number(obj)
        obj = @p2.page 2
        assert_equal 2, @p2.number(obj)
      end
    end

    context "has a method #page that" do
      should "return the requested paged object" do
        obj = @p1.page 1
        assert_equal 1, obj.instance_variable_get(:@__page_num__)
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_nil obj.instance_variable_get(:@metadata)['url_prev']
        assert_nil obj.instance_variable_get(:@metadata)['url_next']
        assert_equal [ '/albums/gallery1/' ], obj.instance_variable_get(:@metadata)['url_pages']

        obj = @p2.page 1
        assert_equal 1, obj.instance_variable_get(:@__page_num__)
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_nil obj.instance_variable_get(:@metadata)['url_prev']
        assert_equal '/albums/Z2FsbGVyeTQ/page-2/', obj.instance_variable_get(:@metadata)['url_next']
        assert_equal [ '/albums/Z2FsbGVyeTQ/', '/albums/Z2FsbGVyeTQ/page-2/' ], obj.instance_variable_get(:@metadata)['url_pages']

        obj = @p2.page 2
        assert_equal 2, obj.instance_variable_get(:@__page_num__)
        assert_equal 1, obj.instance_variable_get(:@images).size
      end

      should "return the current paged object if an invalid number is given" do
        obj = @p1.page
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_equal 1, obj.instance_variable_get(:@__page_num__)

        obj = @p2.page 2
        obj = @p2.page 3
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_equal 2, obj.instance_variable_get(:@__page_num__)
      end
    end

    context "has a method #pages that" do
      should "return an array of paged objects" do
        page1 = @p1.page 1
        assert_equal [ page1 ], @p1.pages
        page1 = @p2.page 1
        page2 = @p2.page 2
        assert_equal [ page1, page2 ], @p2.pages
      end
    end
  end
end
