require 'test_helper'

class TenjiPaginatorTest < Minitest::Test
  context "Tenji::Paginator" do
    setup do
      Tenji::Config.configure
      dir = Pathname.new 'test/data/gallery1/'
      source = Tenji::Gallery.new dir
      @p1 = Tenji::Paginator.new source, 'images', source.metadata['paginate'], source.url
      dir = Pathname.new 'test/data/gallery4/'
      source = Tenji::Gallery.new dir
      @p2 = Tenji::Paginator.new source, 'images', source.metadata['paginate'], source.url 
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

    context "has a method #page that" do
      should "return a page from the source" do
        obj = @p1.page
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_equal 1, obj.instance_variable_get(:@__page_num__) 

        obj = @p2.page 1
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_equal 1, obj.instance_variable_get(:@__page_num__) 
        
        obj = @p2.page 2
        assert_equal 1, obj.instance_variable_get(:@images).size
        assert_equal 2, obj.instance_variable_get(:@__page_num__) 
      end
    end

    context "has a method #pages that" do
      should "return an array of paged objects" do
        # assert_equal [ 1 ], @p1.pages
        # assert_equal [ 1, 2 ], @p2.pages
      end
    end
  end
end
