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
        period_string = '1 January 2018 - 5 January 2018'
        period = Tenji::Utilities.parse_period period_string
        metadata = { 'title' => 'Test Gallery',
                     'description' => 'An example of a gallery.',
                     'period' => period,
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
    
    context "has a class method .parse_period that" do
      should "return an array of Date objects" do
        date_objects = [ '1788-01-26', '1788-01-26', '1776-07-04', '1776-07-04',
                         '1868-10-23', '1868-10-23' ]
        date_strings = [ '26 January 1788', '26/1/1788', 'July 4, 1776',
                         '4/7/1776', '1868 October 23', '1868/10/23' ]
        for index in 0...date_objects.size do
          assert_equal [ Date.parse(date_objects[index]) ],
                       Tenji::Utilities.parse_period(date_strings[index])
        end

        period_object = [ Date.parse('1991-12-20'), Date.parse('1996-03-11') ]
        period_string = '20 December 1991 - 11 March 1996'
        assert_equal period_object, Tenji::Utilities.parse_period(period_string)
      end
    end
  end
end
