require 'test_helper'

class TenjiThumbTest < Minitest::Test
  context "Tenji::Thumb" do
    setup do
      Tenji::Config.configure
      any = AnyType.new
      dir = Pathname.new 'test/data/gallery2'
      file = dir + '01-castle.jpg'
      sizes = Hash.new
      @image = Tenji::Image.new file, sizes, any
      @obj = Tenji::Thumb.new sizes, @image
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Thumb object" do
        assert_equal 'Tenji::Thumb', @obj.class.name
        assert_equal Hash.new, @obj.files
        assert_equal @image, @obj.image
      end
      
      should "raise an error if the arguments are invalid" do
        any = AnyType.new
        t = Tenji::Thumb
        assert_raises(StandardError) { t.new nil, any }
        assert_raises(StandardError) { t.new any, nil }
      end
    end
  end
end
