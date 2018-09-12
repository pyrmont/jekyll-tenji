# frozen_string_literal: true

module Tenji

  # A collection of Liquid filters for use with Tenji
  #
  # @note This document describes the operation of the {Tenji:Filters} module.
  #   For information on how to write Liquid templates for use with Tenji, see
  #   {file:Templating.md}.
  #
  # @since 0.1.0
  # @api public
  module Filters
    using Tenji::Refinements

    # Format the date and time
    #
    # @param datetime [Time] the date and time
    # @param fmt [String] the format for the output
    #
    # @return [String] the formatted date and time
    #
    # @since 0.1.0
    # @api public
    def format_datetime(datetime, fmt = '%e %B %Y')
      return datetime unless datetime.is_a? Time
      datetime.strftime(fmt).strip
    end

    # Format the period
    #
    # @param period [Array<Time>] the period
    # @param sep [String] the separator to use between the periods
    #
    # @return [String] the formatted period
    #
    # @since 0.1.0
    # @api public
    def format_period(period, fmt = '%e %B %Y', sep = '&ndash;')
      return period unless period.is_a? Array
      case period.length
      when 2
        start = period[0].strftime(fmt).strip
        finish = period[1].strftime(fmt).strip
        "#{start}#{sep}#{finish}"
      when 1
        period[0].strftime(fmt).strip
      when 0
        period
      else
        msg = 'Period array contained too many elements'
        raise ::ArgumentError, msg
      end
    end

    # Convert an array of numbers into a coordinate in decimal degree notation
    #
    # @param coord [Array<Numeric, Numeric, Numeric>] the coordinate
    #
    # @return [String] the coordinate in decimal degree notation
    #
    # @since 0.1.0
    # @api public
    def to_dd(coord)
      return coord unless coord.is_a?(Array) && coord.length == 3
      d, m, s = coord
      d.to_f + (m.to_f / 60) + (s.to_f / 3600)
    end

    # Convert an array of numbers into a coordinate in degree minute second
    # notiation
    #
    # The final argument is an optional String specifying the format of the
    # output. The format String uses the following named references: `d` for
    # degree, `m` for minute, `s` for second, `h` for the hemisphere. The
    # default format is `'%{d}&deg; %{m}&prime; %{s}&Prime; %{h}'`.
    #
    # @param coord [Array<Numeric, Numeric, Numeric>] the coordinate
    # @param type ['lat', 'long'] the type of the coordinate
    # @param fmt [String] a format for the output coordinate
    #
    # @return [String] the coordinate in decimal minute second notation
    #
    # @raise [ArgumentError] if `type` is not `'lat'` or `'long'`
    #
    # @since 0.1.0
    # @api public
    def to_dms(coord, type = 'lat', fmt = nil)
      return coord unless coord.is_a?(Array) && coord.length == 3

      d, m, s = coord

      hemisphere = case type
                   when 'lat'
                     (d < 0) ? 'S' : 'N'
                   when 'long'
                     (d < 0) ? 'W' : 'E'
                   else
                     msg = "Parameter `type` must be either 'lat' or 'long'"
                     raise ::ArgumentError, msg
                   end

      d = d.abs
      if s == 0 && m == 0
        degrees = d.floor.to_i
        minutes = (d.modulo(1) * 60).floor.to_i
        seconds = (((d.modulo(1) * 60) - minutes) * 60).round.to_i
      elsif s == 0
        degrees = d.to_i
        minutes = m.floor.to_i
        seconds = (m.modulo(1) * 60).round.to_i
      else
        degrees = d.to_i
        minutes = m.to_i
        seconds = s.to_i
      end

      fmt ||= '%{d}&deg; %{m}&prime; %{s}&Prime; %{h}'
      fmt % { d: degrees, m: minutes, s: seconds, h: hemisphere }
    end

    # Format a number into a float
    #
    # @param num [Numeric] the number
    #
    # @return [Float] the converted number
    #
    # @since 0.1.0
    # @api public
    def to_float(num)
      return num unless num.is_a? Numeric
      num.to_f
    end

    # Format the URL into a URL appropriate for the `srcset` attribute in a
    # `<source>` tag
    #
    # A `<source>` tag has a `srcset` attribute that lists the resources that
    # are available. When nested within a `<picture>` element, the `srcset`
    # attribute will list images for display at different pixel densities. This
    # list is comma-separated, with each resource followed by a string listing
    # the particular density to which it applies, eg. `'/image.jpg,
    # /image@2x.jpg 2x'`.
    #
    # @param link [String] the URL
    #
    # @return [String] the converted URL
    #
    # @since 0.1.0
    # @api public
    def to_srcset(link)
      return link unless link.is_a?(String)

      links = Tenji::Config.scale_factors.map do |f|
                fix = Tenji::Config.scale_suffix(f)
                "#{link.append_to_base(fix)} #{f}x"
              end
      links.join ', '
    end
  end
end

Liquid::Template.register_filter Tenji::Filters
