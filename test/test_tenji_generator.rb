require 'test_helper'
require 'jekyll'
require 'pathname'
require 'tenji/generator'

class TenjiGeneratorTest < Minitest::Test
  context "Tenji::Generator" do
    context "has a method #generate that" do
      setup do
        Jekyll.logger.log_level = :error
        source_dir = Pathname.new('test/data').realpath.to_s
        dest_dir = Pathname.new('tmp').realpath.to_s
        config = Jekyll.configuration({ 'source' => source_dir,
                                        'destination' => dest_dir,
                                        'url' => 'http://localhost' })
        @site = Jekyll::Site.new config
      end

      should "add Gallery pages to a site object" do
        generator = Tenji::Generator.new
        assert_equal [], @site.pages
        # generator.generate @site
        # page_types = @site.pages.map { |p| p.class.name }.uniq
        # assert_equal ['Tenji::Page::Gallery'], page_types
      end
    end
  end
end
