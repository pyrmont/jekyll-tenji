require 'test_helper'
require 'pathname'
require 'tenji/gallery'

class TenjiGalleryTest < Minitest::Test
  context "Tenji::Gallery" do
    context "has a method #initialize that" do
      should "return an object if the directory exists" do
        dir = Pathname.new 'test/data/_albums/gallery1/'
        obj = Tenji::Gallery.new dir: dir
        assert_equal 'Tenji::Gallery', obj.class.name
        assert_equal 'Tenji::Gallery::Metadata', obj.metadata.class.name
        assert_equal [ 'Tenji::Gallery::Image' ],
                     obj.images.map { |i| i.class.name }
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(StandardError) { Tenji::Gallery.new dir }
      end
    end

    context "has a class method .read_yaml that" do
      should "return frontmatter and text if a metadata file exists" do
        metadata = { 'name' => 'Test Gallery',
                     'description' => 'An example of a gallery.',
                     'period' => '1 January 2018 - 5 January 2018',
                     'singles' => true,
                     'paginate' => 15 }
        dir = Pathname.new 'test/data/_albums/gallery2'
        file = dir + Tenji::Gallery::METADATA_FILE 
        data, content = Tenji::Gallery.read_yaml file
        assert_equal 'Hash', data.class.name
        assert_equal metadata, data
        assert_equal 'String', content.class.name
        assert_equal '', content
      end

      should "return {} and nil if a metadata file doesn't exist" do
        dir = Pathname.new 'not/a/real/path'
        file = dir + Tenji::Gallery::METADATA_FILE
        data, content = Tenji::Gallery.read_yaml file
        assert_equal Hash.new, data
        assert_nil content
      end

      should "raise an error if an invalid file is given" do
        file = Pathname.new 'test/data/gallery3/_gallery.md'
        config = { 'strict_front_matter' => true }
        assert_raises(Psych::SyntaxError) do
          capture_io { Tenji::Gallery.read_yaml file, config }
        end
      end
    end
  end
end
