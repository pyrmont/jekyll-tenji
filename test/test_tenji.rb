require 'test_helper'
require 'jekyll'
require 'pathname'
require 'tenji'

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
        subs = @temp_dir.subdirectories
        assert_equal 'albums', subs[0].basename.to_s
        assert_equal 'thumbs', subs[1].basename.to_s
      end
    end
  end
end
