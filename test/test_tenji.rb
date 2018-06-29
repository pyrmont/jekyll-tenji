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
        capture_io do
          @site = TestSite.site source: 'test/data/site', dest: @temp_dir.to_s
        end
      end

      teardown do
        @temp_dir.rmtree
        @site = nil
      end

      should "render a photo gallery" do
        capture_io do
          @site.process
        end
        album_dir = @temp_dir.subdirectories[0]
        assert_equal 'albums', album_dir.basename.to_s
        gallery_dir = album_dir.subdirectories[0]
        thumb_dir = gallery_dir.subdirectories[0]
        assert_equal 'thumbs', thumb_dir.basename.to_s
      end
    end
  end
end
