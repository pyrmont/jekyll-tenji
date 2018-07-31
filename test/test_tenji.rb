require 'test_helper'

class TenjiTest < Minitest::Test
  using Tenji::Refinements

  context "Tenji" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "is a Jekyll plugin that" do
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

      should "render a photo gallery" do
        @site.process
        expected = [ 'albums', 
                     'albums/gallery',
                     'albums/gallery/01-castle.html',
                     'albums/gallery/01-castle.jpg',
                     'albums/gallery/index.html',
                     'albums/gallery/thumbs',
                     'albums/gallery/thumbs/01-castle-cover-2x.jpg',
                     'albums/gallery/thumbs/01-castle-cover.jpg',
                     'albums/gallery/thumbs/01-castle-small-2x.jpg',
                     'albums/gallery/thumbs/01-castle-small.jpg',
                     'albums/index.html' ]
        actual =  @temp_dir.glob('**/*').sort
        assert_equal 11, actual.size
        for i in 0...actual.size do
          assert_equal (@temp_dir + expected[i]).to_s, actual[i].to_s
        end
      end
    end
  end
end
