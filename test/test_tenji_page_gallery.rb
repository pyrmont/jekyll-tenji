require 'test_helper'
require 'tenji/page/gallery'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    context "has a method #initialize that" do
      should "return an object" do
        obj = Tenji::Page::Gallery.new '', '', '', ''
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end
    end
  end
end
