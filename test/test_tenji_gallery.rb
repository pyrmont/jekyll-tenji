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
        obj = Tenji::Gallery.new dir
        assert_equal Tenji::Gallery, obj.class
        assert_equal 'gallery1', obj.dirnames['output']
        assert_equal [ Tenji::Image ], obj.images.map { |i| i.class }
        assert_equal Hash, obj.metadata.class
        assert_equal '', obj.text
      end

      should "initialize the Gallery object with a hidden gallery" do
        dir = Pathname.new 'test/data/gallery4/'
        obj = Tenji::Gallery.new dir
        obfuscated_name = Base64.urlsafe_encode64('gallery4', padding: false)
        assert_equal Tenji::Gallery, obj.class
        assert_equal 'gallery4', obj.dirnames['input']
        assert_equal obfuscated_name, obj.dirnames['output']
      end

      should "initialize the Gallery object with a prefixed directory" do
        dir = Pathname.new 'test/data/05-gallery/'
        obj = Tenji::Gallery.new dir
        assert_equal Tenji::Gallery, obj.class
        assert_equal '05-gallery', obj.dirnames['input']
        assert_equal 'gallery', obj.dirnames['output']
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(Tenji::NotFoundError) do
          Tenji::Gallery.new dir
        end
      end
    end

    context "has a method #<=> that" do
      setup do
        Tenji::Config.configure
        dir = Pathname.new 'test/data/gallery1/'
        @obj = Tenji::Gallery.new dir
        
        @lower_np = AnyType.new(methods: { 'dirnames' => { 'input' => 'a' },
                                          'metadata' => Hash.new })
        @equal_np = AnyType.new(methods: { 'dirnames' => { 'input' => 'gallery1' },
                                          'metadata' => Hash.new })
        @higher_np = AnyType.new(methods: { 'dirnames' => { 'input' => 'z' },
                                           'metadata' => Hash.new })

        years = [ '1/01/1000', '1/01/2000', '1/01/3000' ]
        periods = years.map { |y| { 'period' => [ DateTime.parse(y) ] } }
        @lower_wp = AnyType.new(methods: { 'dirnames' => { 'input' => 'gallery1' },
                                          'metadata' => periods[0] })
        @equal_wp = AnyType.new(methods: { 'dirnames' => { 'input' => 'gallery1' },
                                          'metadata' => periods[1] })
        @higher_wp = AnyType.new(methods: { 'dirnames' => { 'input' => 'gallery1' },
                                           'metadata' => periods[2] })
      end

      teardown do
        Tenji::Config.reset
      end

      should "return a value for comparisons" do
        assert_equal 1, @obj <=> @lower_np
        assert_equal 0, @obj <=> @equal_np
        assert_equal -1, @obj <=> @higher_np

        assert_equal 1, @obj <=> @lower_wp
        assert_equal 1, @obj <=> @equal_wp
        assert_equal 1, @obj <=> @higher_wp

        @obj.instance_variable_set :@metadata, { 'period' => [ DateTime.parse('1/01/2000') ] }

        assert_equal -1, @obj <=> @lower_np
        assert_equal -1, @obj <=> @equal_np
        assert_equal -1, @obj <=> @higher_np

        assert_equal -1, @obj <=> @lower_wp
        assert_equal 0, @obj <=> @equal_wp
        assert_equal 1, @obj <=> @higher_wp
      end

      should "ignore periods if set in the configuration" do
        @obj.instance_variable_set :@metadata, { 'period' => [ DateTime.parse('1/01/2000') ] }
        Tenji::Config.configure({ 'sort' => { 'period' => 'ignore' } })

        assert_equal 1, @obj <=> @lower_np
        assert_equal 0, @obj <=> @equal_np
        assert_equal -1, @obj <=> @higher_np

        assert_equal 0, @obj <=> @lower_wp
        assert_equal 0, @obj <=> @equal_wp
        assert_equal 0, @obj <=> @higher_wp
      end

      should "raise an error if the comparator is not a Tenji::Image" do
        assert_raises(Tenji::TypeError) { @obj <=> nil }
      end
    end

    context "has a method #data that" do
      should "return a Hash object with certain keys set for a gallery with minimal settings" do
        dir = Pathname.new 'test/data/gallery1'
        obj = Tenji::Gallery.new dir
        cover = obj.instance_variable_get(:@cover)
        images = obj.instance_variable_get(:@images)
        data = obj.data
        assert_equal cover, data['cover']
        assert_equal images, data['images']
      end
      
      should "return a Hash object with certain keys set for a gallery with specific settings" do
        dir = Pathname.new 'test/data/gallery4'
        obj = Tenji::Gallery.new dir
        cover = obj.instance_variable_get(:@cover)
        images = obj.instance_variable_get(:@images)
        data = obj.data
        assert_equal cover, data['cover']
        assert_equal images, data['images']
      end
    end

    context "has a method #hidden? that" do
      should "return false if gallery is not hidden" do
        dir = Pathname.new 'test/data/gallery2/'
        obj = Tenji::Gallery.new dir
        assert_equal false, obj.hidden?
      end

      should "return true if gallery is hidden" do
        dir = Pathname.new 'test/data/gallery4/'
        obj = Tenji::Gallery.new dir
        assert_equal true, obj.hidden?
      end
    end

    context "has a method #to_liquid that" do
      setup do
        dir = Pathname.new 'test/data/gallery2/'
        @obj = Tenji::Gallery.new dir
      end

      should "return a Hash object with certain keys set depending on the position" do
        res = @obj.to_liquid
        assert_equal Hash, res.class
        assert_equal "This is a gallery.\n", res['content']
        assert_equal '01-castle-cover.jpg', res['cover'].name
      end
    end
  end
end
