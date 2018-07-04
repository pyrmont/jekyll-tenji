require 'test_helper'

class TenjiImageTest < Minitest::Test
  context "Tenji::Image" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Image object" do
        file = Pathname.new 'test/data/gallery1/photo1.jpg'
        obj = Tenji::Image.new file, Hash.new, '', AnyType.new
        assert_equal 'Tenji::Image', obj.class.name
        assert_equal 'photo1.jpg', obj.name
      end

      should "raise an error if the file doesn't exist" do
        file = Pathname.new 'not/a/real/file'
        assert_raises(StandardError) { Tenji::Image.new(file, 
                                                        Hash.new,
                                                        '',
                                                        AnyType.new) }
      end

      should "raise an error if the arguments are invalid" do
        i = Tenji::Image
        any = AnyType.new
        assert_raises(StandardError) { i.new(nil, any, any, any) }
        assert_raises(StandardError) { i.new(any, nil, any, any) }
        assert_raises(StandardError) { i.new(any, any, nil, any) }
        assert_raises(StandardError) { i.new(any, any, any, nil) }
      end
    end
  end
end
