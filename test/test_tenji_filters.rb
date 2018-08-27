require 'test_helper'

describe Tenji::Filters do
  before do
    filters = class TestObject; include Tenji::Filters end
    @obj = filters.new
  end

  describe "#format_coord" do
    before do
      @format = "%s&deg; %s&prime; %s&Prime; %s"
    end

    it "formats the origin coordinate into a latitude in DMS notation" do
      coord = [ 0, 0, 0 ]
      res = @obj.format_coord coord, 'long'
      assert_equal (@format % [0, 0, 0, 'E']), res
    end

    it "formats a decimal degree coordinate into a latitude in DMS notation" do
      coord = [ -33.8678513, 0, 0 ]
      res = @obj.format_coord coord, 'lat'
      assert_equal (@format % [33, 52, 4, 'S']), res
    end

    it "formats a decimal minute coordinate into a latitude in DMS notation" do
      coord = [ -33, 52.071, 0 ]
      res = @obj.format_coord coord, 'lat'
      assert_equal (@format % [33, 52, 4, 'S']), res
    end

    it "formats a DMS coordinate into a latitude in DMS notation" do
      coord = [ -33, 52, 4 ]
      res = @obj.format_coord coord, 'lat'
      assert_equal (@format % [33, 52, 4, 'S']), res
    end

    it "returns the first argument if not an array of length 3" do
      coord = 'Not an array'
      res = @obj.format_coord(coord)
    end

    it "raises an error if the arguments are invalid" do
      assert_raises(::ArgumentError) { @obj.format_coord([ 0, 0, 0 ], 'not') }
    end
  end

  describe "#format_datetime" do
    before do
      @date = Time.parse '1 January 1901'
    end

    it "returns a formatted string using the default format" do
      res = @obj.format_datetime @date
      assert_equal '1 January 1901', res
    end

    it "returns a formatted string using the given format" do
      res = @obj.format_datetime @date, '%b %d, %Y'
      assert_equal 'Jan 01, 1901', res
    end

    it "returns the first argument if not a Time object" do
      date = 'Not a Time object'
      assert_equal date, @obj.format_datetime(date)
    end
  end

  describe "#format_period" do
    before do
      @period = Hash.new
      @period['double'] = [ DateTime.parse('5 July 1989'), DateTime.parse('14 May 1998') ]
      @period['single'] = [ DateTime.parse('5 July 1989') ]
      @period['empty'] = [ ]
      @period['string'] = 'Not an array'
    end

    it "returns a formatted string for a period with two dates using the default format" do
      res = @obj.format_period @period['double']
      assert_equal '5 July 1989&ndash;14 May 1998', res
    end

    it "returns a formatted string for a period with two dates using the given format" do
      res = @obj.format_period @period['double'], '%Y/%m/%d', ' to '
      assert_equal '1989/07/05 to 1998/05/14', res
    end

    it "returns a formatted string for a period with one date using the default format" do
      res = @obj.format_period @period['single']
      assert_equal '5 July 1989', res
    end

    it "returns a formatted string for a period with one date using the given format" do
      res = @obj.format_period @period['single'], '%A, %b %d'
      assert_equal 'Wednesday, Jul 05', res
    end

    it "returns the first argument if an empty array" do
      assert_equal @period['empty'], @obj.format_period(@period['empty'])
    end

    it "returns the first argument if not an array" do
      assert_equal @period['string'], @obj.format_period(@period['string'])
    end

    it "raise an error if the arguments are invalid" do
      assert_raises(::ArgumentError) { @obj.format_period([ 0, 0, 0 ]) }
    end
  end

  describe "#to_float" do
    it "returns a float if given an integer" do
      assert_equal 1.0, @obj.to_float(1)
    end

    it "returns a float if given a rational" do
      assert_equal 0.5, @obj.to_float(Rational(1, 2))
    end

    it "returns a float if given zero" do
      assert_equal 0.0, @obj.to_float(0)
    end

    it "return the argument if not a Numeric object" do
      num = 'Not a number'
      assert_equal num, @obj.to_float(num)
    end
  end

  describe "#to_srcset" do
    before do
      Tenji::Config.configure
    end

    after do
      Tenji::Config.reset
    end

    it "returns a string in the appropriate format" do
      link = 'image.jpg'
      res = @obj.to_srcset link
      assert_equal 'image.jpg 1x, image-2x.jpg 2x', res
    end

    it "returns the argument if not a String object" do
      link = 10
      assert_equal link, @obj.to_srcset(link)
    end
  end
end
