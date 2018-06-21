require 'test_helper'

class TenjiThumbTest < Minitest::Test
  context "Tenji::Thumb" do
    setup do
      dir = Pathname.new 'test/data/gallery2'
      @file = dir + '01-castle.jpg'
      @obj = Tenji::Thumb.new Hash.new, AnyType.new
    end

    context "has a method #initialize that" do
      should "return an object if passed a path" do
        assert_equal 'Tenji::Thumb', @obj.class.name
        assert_equal Hash.new, @obj.files
      end
    end
  end
end
