require 'test_helper'

class TenjiUtilitiesTest < Minitest::Test
  context "Tenji::Utilities" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a class method .read_yaml that" do
      should "return frontmatter and text if a metadata file exists" do
        metadata = { 'name' => 'Test Gallery',
                     'description' => 'An example of a gallery.',
                     'period' => '1 January 2018 - 5 January 2018',
                     'singles' => true,
                     'paginate' => 15 }
        dir = Pathname.new 'test/data/gallery2'
        file = dir + Tenji::Config.file(:metadata) 
        data, content = Tenji::Utilities.read_yaml file
        assert_equal 'Hash', data.class.name
        assert_equal metadata, data
        assert_equal 'String', content.class.name
        assert_equal '', content
      end

      should "return {} and '' if a metadata file doesn't exist" do
        dir = Pathname.new 'not/a/real/path'
        file = dir + Tenji::Config.file(:metadata)
        data, content = Tenji::Utilities.read_yaml file
        assert_equal Hash.new, data
        assert_equal '', content
      end

      should "raise an error if an invalid file is given" do
        dir = Pathname.new 'test/data/gallery3'
        file = dir + Tenji::Config.file(:metadata)
        config = { 'strict_front_matter' => true }
        assert_raises(Psych::SyntaxError) do
          capture_io { Tenji::Utilities.read_yaml file, config }
        end
      end
    end
  end
end
