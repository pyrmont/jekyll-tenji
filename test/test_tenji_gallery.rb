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
      should "return an object if the directory exists" do
        dir = Pathname.new 'test/data/gallery1/'
        obj = Tenji::Gallery.new dir, AnyType.new
        assert_equal 'Tenji::Gallery', obj.class.name
        assert_equal 'Hash', obj.metadata.class.name
        assert_equal [ 'Tenji::Image' ], obj.images.map { |i| i.class.name }
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(StandardError) { Tenji::Gallery.new dir }
      end
    end
  end
end
