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
        @constraints = { 'x' => 400, 'y' => 400 }
        @resize_function = 'fit'
        @obj = Tenji::Thumb.new 'small', @constraints, @resize_function, @image
      end

      should "initialise a Thumb object" do
        assert_equal Tenji::Thumb, @obj.class
        assert_equal '01-castle-small.jpg', @obj.name
        assert_equal 'small', @obj.size
        assert_equal @constraints, @obj.constraints
        assert_equal @resize_function, @obj.resize_function
        assert_equal @image, @obj.source
      end

      should "raise an error if the arguments are invalid" do
        any = AnyType.new
        t = Tenji::Thumb
        assert_raises(Tenji::TypeError) { t.new nil, any, any, any }
        assert_raises(Tenji::TypeError) { t.new any, nil, any, any }
        assert_raises(Tenji::TypeError) { t.new any, any, nil, any }
        assert_raises(Tenji::TypeError) { t.new any, any, any, nil }
      end
    end

    context "has a method #to_liquid that" do
      setup do
        dir = Pathname.new 'test/data/gallery2'
        file = dir + '01-castle.jpg'
        gallery = AnyType.new(methods: { 'dirnames' => { 'output' => 'gallery2' }})
        @image = Tenji::Image.new file, Hash.new, gallery
        @dimensions = { 'x' => 400, 'y' => 400 }
        @resize = 'fit'
        @obj = Tenji::Thumb.new 'small', @dimensions, @resize, @image
      end

      should "return a Hash object with certain keys set" do
        res = @obj.to_liquid()
        assert_equal Hash, res.class
        assert_equal '01-castle-small.jpg', res['name']
        assert_equal '/albums/gallery2/thumbs/01-castle-small.jpg', res['url']
        assert_equal 'small', res['size']
        assert_equal @image, res['source']
      end
    end
  end
end
