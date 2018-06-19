require 'test_helper'
require 'pathname'
require 'tenji/gallery/image/thumb'

class TenjiGalleryImageThumbTest < Minitest::Test
  context "Tenji::Gallery::Image::Thumb" do
    setup do
      @file = Pathname.new 'test/data/gallery2/01-castle.jpg'
      @obj = Tenji::Gallery::Image::Thumb.new Hash.new
    end

    context "has a method #initialize that" do
      should "return an object if passed a path" do
        assert_equal 'Tenji::Gallery::Image::Thumb', @obj.class.name
        assert_equal Hash.new, @obj.files
      end
    end
  end
end
