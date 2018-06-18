require 'test_helper'
require 'pathname'
require 'tenji/gallery/metadata'

class TenjiGalleryMetadataTest < Minitest::Test
  context "Tenji::Gallery::Metadata" do
    context "has a method #initialize that" do
      should "return a default object when no metadata is passed" do
        obj = Tenji::Gallery::Metadata.new Hash.new, 'gallery1'
        assert_equal 'Tenji::Gallery::Metadata', obj.class.name
        assert_equal 'gallery1', obj['name']
        assert_equal '', obj['description']
        assert_equal Array.new, obj['period']
        assert_equal false, obj['singles']
        assert_equal 25, obj['paginate']
      end

      should "return a custom object when metadata is passed" do
        metadata = { 'name' => 'Test Gallery',
                     'description' => 'An example of a gallery.',
                     'period' => '1 January 2018 - 5 January 2018',
                     'singles' => true,
                     'paginate' => 15 }
        obj = Tenji::Gallery::Metadata.new metadata, 'gallery2'
        period = [ Date.parse('1 January 2018'), Date.parse('5 January 2018') ]
        assert_equal 'Tenji::Gallery::Metadata', obj.class.name
        assert_equal 'Test Gallery', obj['name']
        assert_equal 'An example of a gallery.', obj['description']
        assert_equal period, obj['period']
        assert_equal true, obj['singles']
        assert_equal 15, obj['paginate']
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
                       Tenji::Gallery::Metadata.parse_period(date_strings[index])
        end

        period_object = [ Date.parse('1991-12-20'), Date.parse('1996-03-11') ]
        period_string = '20 December 1991 - 11 March 1996'
        assert_equal period_object, 
                     Tenji::Gallery::Metadata.parse_period(period_string)
      end
    end
  end
end
