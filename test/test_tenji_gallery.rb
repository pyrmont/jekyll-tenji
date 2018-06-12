require 'test_helper'
require 'pathname'
require 'tenji/gallery'

class TenjiGalleryTest < Minitest::Test
  context "Tenji::Gallery" do
    context "has a method #initialize that" do
      should "return an object if the directory exists" do
        dir = Pathname.new 'test/data/_albums/gallery1/'
        obj = Tenji::Gallery.new dir: dir
        assert_equal 'Tenji::Gallery', obj.class.name
        assert_equal 'Tenji::Gallery::Metadata', obj.metadata.class.name
        assert_equal [ 'Tenji::Gallery::Image' ], obj.images.map { |i| i.class.name }
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(StandardError) { Tenji::Gallery.new dir }
      end
    end
  end
end
