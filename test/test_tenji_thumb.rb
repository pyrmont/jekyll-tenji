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
        @obj = Tenji::Thumb.new 'small', @dimensions, @image
      end

      should "initialise a Thumb object" do
        assert_equal Tenji::Thumb, @obj.class
        assert_equal '01-castle-small.jpg', @obj.name
        assert_equal 'small', @obj.size
        assert_equal @dimensions, @obj.dimensions
        assert_equal @image, @obj.source
      end

      should "raise an error if the arguments are invalid" do
        any = AnyType.new
        t = Tenji::Thumb
        assert_raises(Tenji::TypeError) { t.new nil, any, any }
        assert_raises(Tenji::TypeError) { t.new any, nil, any }
        assert_raises(Tenji::TypeError) { t.new any, any, nil }
      end
    end

    context "has a method #to_liquid that" do
      setup do
        dir = Pathname.new 'test/data/gallery2'
        file = dir + '01-castle.jpg'
        gallery = AnyType.new(methods: { 'dirname' => 'gallery2' })
        @image = Tenji::Image.new file, Hash.new, gallery
        @dimensions = { 'x' => 400, 'y' => 400 }
        @obj = Tenji::Thumb.new 'small', @dimensions, @image
      end

      should "return a Hash object with certain keys set" do
        res = @obj.to_liquid()
        assert_equal Hash, res.class
        assert_equal '01-castle-small.jpg', res['name']
        assert_equal '/albums/gallery2/thumbs/01-castle-small.jpg', res['link']
        assert_equal 400, res['x']
        assert_equal 400, res['y']
        assert_equal 'small', res['size']
        assert_equal @image, res['source']
      end
    end
  end
end
