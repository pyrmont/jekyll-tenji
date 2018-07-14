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
        obj = Tenji::Image.new file, Hash.new, AnyType.new
        assert_equal 'Tenji::Image', obj.class.name
        assert_equal 'photo1.jpg', obj.name
      end

      should "raise an error if the file doesn't exist" do
        file = Pathname.new 'not/a/real/file'
        assert_raises(Tenji::NotFoundError) do
          Tenji::Image.new(file, Hash.new, AnyType.new)
        end
      end

      should "raise an error if the arguments are invalid" do
        i = Tenji::Image
        any = AnyType.new
        assert_raises(Tenji::TypeError) { i.new(nil, any, any) }
        assert_raises(Tenji::TypeError) { i.new(any, nil, any) }
        assert_raises(Tenji::TypeError) { i.new(any, any, nil) }
      end
    end

    context "has a method #<=> that" do
      setup do
        file = Pathname.new 'test/data/gallery1/photo1.jpg'
        @obj = Tenji::Image.new file, Hash.new, AnyType.new
      end

      should "return a value for comparisons" do
        lower = AnyType.new(methods: { 'name' => 'a' })
        equal = AnyType.new(methods: { 'name' => 'photo1.jpg' })
        higher = AnyType.new(methods: { 'name' => 'z' })
        assert_equal 1, @obj <=> lower
        assert_equal 0, @obj <=> equal
        assert_equal -1, @obj <=> higher
      end

      should "raise an error if the comparison is not a Tenji::Image" do
        assert_raises(Tenji::TypeError) { @obj <=> nil }
      end
    end

    context "has a method #data that" do
      setup do
        file = Pathname.new 'test/data/gallery1/photo1.jpg'
        gallery = AnyType.new(methods: { 'dirname' => 'gallery1', 'images' => Array.new(3) })
        @obj = Tenji::Image.new file, Hash.new, gallery
      end

      should "return a Hash object with certain keys set depending on the position" do
        res = @obj.data
        assert_equal Hash, res.class
        assert_equal Hash, res['image'].class

        @obj.position = 0
        res = @obj.data
        assert_equal Hash, res.class
        assert_equal 1, res['next']
        assert_nil res['prev']

        @obj.position = 1
        res = @obj.data
        assert_equal Hash, res.class
        assert_equal 2, res['next']
        assert_equal 0, res['prev']

        @obj.position = 2
        res = @obj.data
        assert_equal Hash, res.class
        assert_nil res['next']
        assert_equal 1, res['prev']
      end
    end

    context "has a method #to_liquid that" do
      setup do
        file = Pathname.new 'test/data/gallery2/01-castle.jpg'
        gallery = AnyType.new(methods: { 'dirname' => 'gallery2' })
        @obj = Tenji::Image.new file, Hash.new, gallery
      end

      should "return a Hash object with certain keys set depending on the position" do
        res = @obj.to_liquid
        assert_equal Hash, res.class
        assert_equal "This is an image.\n", res['content']
        assert_equal '01-castle.jpg', res['name']
      end
    end

    context "has a private method #image that" do
      setup do
        file = Pathname.new 'test/data/gallery2/01-castle.jpg'
        gallery = AnyType.new(methods: { 'dirname' => 'gallery2' })
        @obj = Tenji::Image.new file, Hash.new, gallery
        @obj.position = 1
      end

      should "return a Hash object" do
        res = @obj.send :image
        assert_equal '01-castle.jpg', res['name']
        assert 1, res['position']
        assert_equal '/albums/gallery2/01-castle.jpg', res['link']
        assert_equal '/albums/gallery2/01-castle.html', res['page_link']
        assert_equal 2048, res['x']
        assert_equal 1536, res['y']
      end
    end

    context "has a private method #title_from_name that" do
      setup do
        file = Pathname.new 'test/data/gallery2/01-castle.jpg'
        @obj = Tenji::Image.new file, Hash.new, AnyType.new
      end

      should "return a String" do
        res = @obj.send :title_from_name
        assert_equal 'castle.jpg', res

        @obj.instance_variable_set(:@name, '-01-castle.jpg')
        res = @obj.send :title_from_name
        assert_equal '-01-castle.jpg', res
      end
    end
  end
end
