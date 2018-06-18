require 'test_helper'
require 'pathname'
require 'tenji/gallery/image'

class TenjiGalleryImageTest < Minitest::Test
  context "Tenji::Gallery::Image" do
    context "has a method #initialize that" do
      should "return an object if the file exists" do
        file = Pathname.new 'test/data/gallery1/photo1.jpg'
        obj = Tenji::Gallery::Image.new file
        assert_equal 'Tenji::Gallery::Image', obj.class.name
        assert_equal 'photo1.jpg', obj.name
      end

      should "raise an error if the file doesn't exist" do
        file = Pathname.new 'not/a/real/file'
        assert_raises(StandardError) { Tenji::Gallery::Image.new file }
      end
    end
  end
end
