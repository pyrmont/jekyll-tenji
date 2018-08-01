require 'test_helper'

class TenjiUtilitiesTest < Minitest::Test
  context "Tenji::Utilities" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a class method .parse_period that" do
      should "return an array of Date objects" do
        date_numbers = [ '1788-01-26', '1788-01-26', '1776-07-04', '1776-07-04',
                         '1868-10-23', '1868-10-23' ]
        date_strings = [ '26 January 1788', '26/1/1788', 'July 4, 1776',
                         '4/7/1776', '1868 October 23', '1868/10/23' ]
        for index in 0...date_numbers.size do
          assert_equal [ Date.parse(date_numbers[index]) ],
                       Tenji::Utilities.parse_period(date_strings[index])
        end

        period_object = [ Date.parse('1991-12-20'), Date.parse('1996-03-11') ]
        period_string = '20 December 1991 - 11 March 1996'
        assert_equal period_object, Tenji::Utilities.parse_period(period_string)
      end

      should "raise an error if argument is invalid" do
        assert_raises(Tenji::TypeError) { Tenji::Utilities.parse_period nil }
      end
    end

    context "has a class method .read_exif that" do
      should "return a Hash object of EXIF data" do
        file = Pathname.new 'test/data/gallery4/03-with-exif.jpg'
        res = Tenji::Utilities.read_exif file
        assert_equal Hash, res.class
        assert_equal res['gps_latitude_ref'], 'N'
        assert (res['gps_latitude'][0] > 0)
        assert_equal res['gps_longitude_ref'], 'E'
        assert (res['gps_longitude'][0] > 0)

        file = Pathname.new 'test/data/gallery4/04-other-exif.jpg'
        res = Tenji::Utilities.read_exif file
        assert_equal Hash, res.class
        assert_equal res['gps_latitude_ref'], 'S'
        assert (res['gps_latitude'][0] < 0)
        assert_equal res['gps_longitude_ref'], 'E'
        assert (res['gps_longitude'][0] > 0)
      end

      should "return an empty Hash object if the file doesn't exist" do
        file = Pathname.new 'test/not/a/file'
        res = Tenji::Utilities.read_exif file
        assert_equal Hash, res.class
        assert res.empty?
      end
    end

    context "has a class method .read_yaml that" do
      should "return frontmatter and text if a metadata file exists" do
        period_string = '1 January 2018 - 5 January 2018'
        period = Tenji::Utilities.parse_period period_string
        metadata = { 'title' => 'Test Gallery',
                     'description' => 'An example of a gallery.',
                     'period' => period,
                     'individual_pages' => true,
                     'paginate' => 15 }
        dir = Pathname.new 'test/data/gallery2'
        file = dir + Tenji::Config.file('metadata')
        data, content = Tenji::Utilities.read_yaml file
        assert_equal metadata, data
        assert_equal "This is a gallery.\n", content
      end

      should "return empty objects if a metadata file doesn't exist" do
        dir = Pathname.new 'not/a/real/path'
        file = dir + Tenji::Config.file('metadata')
        data, content = Tenji::Utilities.read_yaml file
        assert_equal Hash.new, data
        assert_equal '', content
      end

      should "raise an error if an invalid file is given" do
        dir = Pathname.new 'test/data/gallery3'
        file = dir + Tenji::Config.file('metadata')
        config = { 'strict_front_matter' => true }
        assert_raises(Psych::SyntaxError) do
          capture_io { Tenji::Utilities.read_yaml file, config }
        end
      end

      should "raise an error for invalid arguments" do
        u = Tenji::Utilities
        file = Pathname.new('test/data/gallery1') + Tenji::Config.file('metadata')
        assert_raises(Tenji::TypeError) { u.read_yaml file, nil }
        assert_raises(Tenji::TypeError) { u.read_yaml nil, Hash.new }
      end
    end
  end
end
