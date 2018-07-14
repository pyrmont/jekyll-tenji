require 'test_helper'

class TenjiFiltersTest < Minitest::Test
  context "Tenji::Filters" do
    setup do
      filters = class TestObject; include Tenji::Filters end
      @obj = filters.new
    end

    context "has a method #format_coord that" do
      should "format a coordinate into a String written in DMS notation" do
        format = "%s&deg; %s&prime; %s&Prime; %s"
        coord = [ 0, 0, 0 ]
        res = @obj.format_coord coord, 'long'
        assert_equal (format % [0, 0, 0, 'E']), res

        coord = [ -33.8678513, 0, 0 ]
        res = @obj.format_coord coord, 'lat'
        assert_equal (format % [33, 52, 4, 'S']), res

        coord = [ -33, 52.071, 0 ]
        res = @obj.format_coord coord, 'lat'
        assert_equal (format % [33, 52, 4, 'S']), res

        coord = [ -33, 52, 4 ]
        res = @obj.format_coord coord, 'lat'
        assert_equal (format % [33, 52, 4, 'S']), res
      end

      should "return the first argument if not an array of length 3" do
        coord = 'Not an array'
        res = @obj.format_coord(coord)
      end

      should "raise an error if the arguments are invalid" do
        assert_raises(::ArgumentError) { @obj.format_coord([ 0, 0, 0 ], 'not') }
      end
    end

    context "has a method #format_datetime that" do
      should "return a formatted String" do
        date = Time.parse '26 January 1788'

        res = @obj.format_datetime date
        assert_equal '26 January 1788', res

        res = @obj.format_datetime date, '%b %d, %Y'
        assert_equal 'Jan 26, 1788', res
      end

      should "return the first argument if not a Time object" do
        date = 'Not a Time object'
        assert_equal date, @obj.format_datetime(date)
      end
    end

    context "has a method #format_period that" do
      should "return a formatted String for a period with two dates" do
        period = [ DateTime.parse('5 July 1989'), DateTime.parse('14 May 1998') ]

        res = @obj.format_period period
        assert_equal '5 July 1989&ndash;14 May 1998', res

        res = @obj.format_period period, '%Y/%m/%d', ' to '
        assert_equal '1989/07/05 to 1998/05/14', res
      end

      should "return a formatted String for a period with one date" do
        period = [ DateTime.parse('5 July 1989') ]

        res = @obj.format_period period
        assert_equal '5 July 1989', res

        res = @obj.format_period period, '%A, %b %d'
        assert_equal 'Wednesday, Jul 05', res
      end

      should "return the first argument if not an array" do
        period = 'Not an array'
        assert_equal period, @obj.format_period(period)
      end

      should "raise an error if the arguments are invalid" do
        assert_raises(StandardError) { @obj.format_period([ 0, 0, 0 ]) }
      end
    end

    context "has a method #to_float that" do
      should "return a float" do
        assert_equal 1.0, @obj.to_float(1)
        assert_equal 0.5, @obj.to_float(Rational(1, 2))
        assert_equal 0.0, @obj.to_float(0)
      end

      should "return the argument if not a Numeric object" do
        num = 'Not a number'
        assert_equal num, @obj.to_float(num)
      end
    end

    context "has a method #to_srcset that" do
      setup do
        Tenji::Config.configure
      end

      teardown do
        Tenji::Config.reset
      end

      should "return a String in the appropriate format" do
        link = 'image.jpg'
        res = @obj.to_srcset link
        assert_equal 'image.jpg 1x, image-2x.jpg 2x', res
      end

      should "return the argument if not a Numeric object" do
        link = 10
        assert_equal link, @obj.to_srcset(link)
      end
    end
  end
end
