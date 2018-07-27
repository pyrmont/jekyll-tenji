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
        @generator = Tenji::Generator.new
      end

      teardown do
        @temp_dir.rmtree
        @site = nil
      end

      should "add Gallery pages to a site object" do
        assert_equal [], @site.pages
        assert_equal [], @site.static_files

        @generator.generate @site

        pages = @site.pages
        assert_equal [ Tenji::Page::Gallery, Tenji::Page::Image, Tenji::Page::List ],
                     pages.map { |p| p.class }.uniq
        assert_equal [ 'index.html', '01-castle.html', 'index.html' ],
                     pages.map { |p| p.name }

        files = @site.static_files
        assert_equal [ Tenji::File::Image, Tenji::File::Thumb ],
                     files.map { |f| f.class }.uniq
        filenames = [ '01-castle.jpg', '01-castle-small.jpg', '01-castle-small-2x.jpg' ]
        assert_equal filenames, files.map { |f| f.name }
      end

      should "raise an error with invalid arguments" do
        assert_raises(Tenji::TypeError) { @generator.generate nil }
      end
    end
  end
end
