require 'test_helper'

class TenjiGeneratorTest < Minitest::Test
  context "Tenji::Generator" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #generate that" do
      setup do
        subdir = ('a'..'z').to_a.shuffle[0,8].join
        @temp_dir = Pathname.new('tmp/' + subdir)
        @temp_dir.mkpath
        @site = TestSite.site source: 'test/data/site', dest: @temp_dir.to_s
      end

      teardown do
        @temp_dir.rmtree
        @site = nil 
      end

      should "add Gallery pages to a site object" do
        generator = Tenji::Generator.new
        assert_equal [], @site.pages
        generator.generate @site
        pages = @site.pages
        assert_equal [ 'Tenji::Page::Gallery', 'Tenji::Page::Image' ], 
                     pages.map { |p| p.class.name }.uniq
        assert_equal [ 'index.html', '01-castle.jpg.html' ], 
                     pages.map { |p| p.name }
        files = @site.static_files
        assert_equal [ 'Tenji::File::Image', 'Tenji::File::Thumb' ], 
                     files.map { |f| f.class.name }.uniq
        assert_equal [ '01-castle.jpg', '01-castle-small.jpg' ], 
                     files.map { |f| f.name }
      end
    end
  end
end
