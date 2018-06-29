require 'test_helper'

class TenjiThumbTest < Minitest::Test
  context "Tenji::Thumb" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      setup do
        dir = Pathname.new 'test/data/gallery2'
        file = dir + '01-castle.jpg'
        @image = Tenji::Image.new file, Hash.new, AnyType.new
        @dimensions = { 'x' => 400, 'y' => 400 }
        @obj = Tenji::Thumb.new 'small', @dimensions , @image
      end

      should "initialise a Thumb object" do
        assert_equal 'Tenji::Thumb', @obj.class.name
        assert_equal '01-castle-small.jpg', @obj.name
        assert_equal 'small', @obj.size
        assert_equal @dimensions, @obj.dimensions
        assert_equal @image, @obj.source
      end
      
      should "raise an error if the arguments are invalid" do
        any = AnyType.new
        t = Tenji::Thumb
        assert_raises(StandardError) { t.new nil, any, any }
        assert_raises(StandardError) { t.new any, nil, any }
        assert_raises(StandardError) { t.new any, any, nil }
      end
    end
  end
end
