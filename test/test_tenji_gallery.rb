require 'test_helper'

class TenjiGalleryTest < Minitest::Test
  context "Tenji::Gallery" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialize the Gallery object if the directory exists" do
        dir = Pathname.new 'test/data/gallery1/'
        list = Tenji::List.new dir
        obj = Tenji::Gallery.new dir, list
        assert_equal 'Tenji::Gallery', obj.class.name
        assert_equal 'gallery1', obj.dirname
        assert_equal [ 'Tenji::Image' ], obj.images.map { |i| i.class.name }
        assert_equal 'Tenji::List', obj.list.class.name
        assert_equal 'Hash', obj.metadata.class.name
        assert_equal '', obj.text
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(Tenji::NotFoundError) do
          Tenji::Gallery.new dir, AnyType.new
        end
      end

      should "raise an error if the list does not exist" do
        dir = Pathname.new 'test/data/gallery1/'
        assert_raises(Tenji::TypeError) { Tenji::Gallery.new dir, nil }
      end
    end

    context "has a method #<=> that" do
      setup do
        dir = Pathname.new 'test/data/gallery1/'
        @obj = Tenji::Gallery.new dir, AnyType.new
      end

      should "return a value for comparisons" do
        lower_np = AnyType.new(methods: { 'dirname' => 'a',
                                          'metadata' => Hash.new })
        equal_np = AnyType.new(methods: { 'dirname' => 'gallery1',
                                          'metadata' => Hash.new })
        higher_np = AnyType.new(methods: { 'dirname' => 'z',
                                           'metadata' => Hash.new })

        years = [ '1/01/1000', '1/01/2000', '1/01/3000' ]
        periods = years.map { |y| { 'period' => [ DateTime.parse(y) ] } }
        lower_wp = AnyType.new(methods: { 'dirname' => 'gallery1',
                                          'metadata' => periods[0] })
        equal_wp = AnyType.new(methods: { 'dirname' => 'gallery1',
                                          'metadata' => periods[1] })
        higher_wp = AnyType.new(methods: { 'dirname' => 'gallery1',
                                           'metadata' => periods[2] })

        assert_equal 1, @obj <=> lower_np
        assert_equal 0, @obj <=> equal_np
        assert_equal -1, @obj <=> higher_np

        assert_equal 1, @obj <=> lower_wp
        assert_equal 1, @obj <=> equal_wp
        assert_equal 1, @obj <=> higher_wp

        @obj.instance_variable_set :@metadata, { 'period' => [ DateTime.parse('1/01/2000') ] }

        assert_equal -1, @obj <=> lower_np
        assert_equal -1, @obj <=> equal_np
        assert_equal -1, @obj <=> higher_np

        assert_equal -1, @obj <=> lower_wp
        assert_equal 0, @obj <=> equal_wp
        assert_equal 1, @obj <=> higher_wp
      end

      should "raise an error if the comparator is not a Tenji::Image" do
        assert_raises(Tenji::TypeError) { @obj <=> nil }
      end
    end

    context "has a method #to_liquid that" do
      setup do
        dir = Pathname.new 'test/data/gallery2/'
        @obj = Tenji::Gallery.new dir, AnyType.new
      end

      should "return a Hash object with certain keys set depending on the position" do
        res = @obj.to_liquid
        assert_equal Hash, res.class
        assert_equal 'gallery2', res['dirname']
        assert_equal "This is a gallery.\n", res['content']
        assert_equal '01-castle.jpg', res['cover'].name
      end
    end

    context "has a private method #init_cover that" do
      setup do
        dir = Pathname.new 'test/data/gallery2/'
        @obj = Tenji::Gallery.new dir, AnyType.new
      end

      should "return an Image object" do
        fm = { 'cover' => '01-castle.jpg' }
        res = @obj.send :init_cover, fm
        assert_equal '01-castle.jpg', res.name
        fm = { 'cover' => 'not-real.jpg' }
        res = @obj.send :init_cover, fm
        assert_nil res
      end
    end
  end
end
