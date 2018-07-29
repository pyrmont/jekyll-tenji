require 'test_helper'

class TenjiGeneratorGalleryTest < Minitest::Test
  context "Tenji::Generator::Gallery" do
    setup do
      Tenji::Config.configure
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @dir = Pathname.new 'test/data/gallery2'
      @gallery = Tenji::Gallery.new @dir
      @base = Pathname.new @site.source
      @generator = Tenji::Generator::Gallery.new @gallery, @site, @base
    end

    teardown do
      Tenji::Config.reset
      @site = nil
    end

    context "has a method #initialize that" do
      should "initialize a Generator::Gallery object" do
        obj = Tenji::Generator::Gallery.new @gallery, @site, @base
        assert_equal Tenji::Generator::Gallery, obj.class
      end

      should "raise an error if the arguments are invalid" do
        gg = Tenji::Generator::Gallery
        assert_raises(Tenji::TypeError) { gg.new nil, @site, @base }
        assert_raises(Tenji::TypeError) { gg.new @gallery, nil, @base }
        assert_raises(Tenji::TypeError) { gg.new @gallery, @site, nil }
      end
    end

    context "has a method #generate_images that" do
      should "update a provided object" do
        files = Array.new
        @generator.generate_images files
        assert_equal [ Tenji::File::Image ], files.map { |f| f.class }.uniq
      end

      should "raise an error if an invalid object is provided" do
        assert_raises(Tenji::TypeError) { @generator.generate_images nil }
      end
    end

    context "has a method #generate_index that" do
      should "add to an array of Page objects" do
        pages = Array.new
        @generator.generate_index pages
        assert_equal [ Tenji::Page::Gallery ], pages.map { |p| p.class }.uniq
      end

      should "raise an error if an invalid object is provided" do
        assert_raises(Tenji::TypeError) { @generator.generate_index nil }
      end
    end

    context "has a method #generate_individual_pages that" do
      should "add to an array of Page objects" do
        pages = Array.new
        @generator.generate_individual_pages pages
        assert_equal [ Tenji::Page::Image ], pages.map { |p| p.class }.uniq
      end

      should "raise an error if an invalid object is provided" do
        assert_raises(Tenji::TypeError) do
          @generator.generate_individual_pages nil
        end
      end
    end

    context "has a method #generate_thumbs that" do
      should "add to an array of File::Thumb objects" do
        files = Array.new
        @generator.generate_thumbs files
        assert_equal [ Tenji::File::Thumb ], files.map { |f| f.class }.uniq
      end

      should "raise an error if an invalid object is provided" do
        assert_raises(Tenji::TypeError) { @generator.generate_thumbs nil }
      end
    end
  end
end
