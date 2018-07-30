require 'test_helper'

class TenjiGeneratorTest < Minitest::Test
  context "Tenji::Generator" do
    setup do
      Tenji::Config.configure
      subdir = ('a'..'z').to_a.shuffle[0,8].join
      @temp_dir = Pathname.new('tmp/' + subdir)
      @temp_dir.mkpath
      @site = TestSite.site source: 'test/data/site', dest: @temp_dir.to_s
      @generator = Tenji::Generator.new
    end

    teardown do
      Tenji::Config.reset
      @temp_dir.rmtree
      @site = nil
    end

    context "has a method #generate that" do
      should "add Gallery pages to a site object" do
        assert_equal [], @site.pages
        assert_equal [], @site.static_files

        @generator.generate @site

        pages = @site.pages
        assert_equal [ Tenji::Page::Gallery, Tenji::Page::Image, Tenji::Page::List ],
                     pages.map { |p| p.class }
        assert_equal [ 'index.html', '01-castle.html', 'index.html' ],
                     pages.map { |p| p.name }

        files = @site.static_files
        assert_equal [ Tenji::File::Image, Tenji::File::Thumb, Tenji::File::Thumb ],
                     files.map { |f| f.class }
        filenames = [ '01-castle.jpg', '01-castle-small.jpg', '01-castle-small-2x.jpg' ]
        assert_equal filenames, files.map { |f| f.name }
      end

      should "raise an error with invalid arguments" do
        assert_raises(Tenji::TypeError) { @generator.generate nil }
      end
    end

    context "has a private method #add_tenji that" do
      should "add a Hash object to a payload variable" do
        @generator.generate @site
        galleries = @generator.instance_variable_get(:@galleries)
        payload = Hash.new
        @generator.send :add_tenji, @site, payload
        obj = payload['tenji']
        assert_equal Hash, obj.class
        assert_equal galleries['all'], obj['all_galleries']
        assert_equal galleries['listed'], obj['galleries']
        assert_equal galleries['hidden'], obj['hidden_galleries']
      end
    end
  end
end
