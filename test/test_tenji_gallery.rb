require 'test_helper'

class TenjiGalleryTest < Minitest::Test
  context "Tenji::Gallery" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialize the Gallery object if the directory exists" do
        dir = Pathname.new 'test/data/gallery1/'
        list = Tenji::List.new dir
        obj = Tenji::Gallery.new dir, list
        assert_equal 'Tenji::Gallery', obj.class.name
        assert_equal 'gallery1', obj.dirname
        assert_equal [ 'Tenji::Image' ], obj.images.map { |i| i.class.name }
        assert_equal 'Tenji::List', obj.list.class.name
        assert_equal 'Hash', obj.metadata.class.name
        assert_equal '', obj.text
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(StandardError) { Tenji::Gallery.new dir, AnyType.new }
      end
      
      should "raise an error if the list does not exist" do
        dir = Pathname.new 'test/data/gallery1/'
        assert_raises(StandardError) { Tenji::Gallery.new dir, nil }
      end
    end
  end
end
