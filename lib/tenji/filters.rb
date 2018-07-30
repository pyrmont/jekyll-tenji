# frozen_string_literal: true

module Tenji
  module Filters
    using Tenji::Refinements

    def format_coord(coord, type = 'lat')
      return coord unless coord.is_a?(Array) && coord.length == 3

      d, m, s = coord

      return (d.to_f + (m.to_f / 60) + (s.to_f / 3600)) if type == 'decimal'

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

      %Q[#{degrees}&deg; #{minutes}&prime; #{seconds}&Prime; #{hemisphere}]
    end

    def format_datetime(datetime, fmt = '%e %B %Y')
      return datetime unless datetime.is_a? Time
      datetime.strftime(fmt).strip
    end

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

    def to_float(num)
      return num unless num.is_a? Numeric
      num.to_f
    end

    def to_srcset(link)
      return link unless link.is_a?(String)

      pos = link.rindex '.'
      factors = 1..Tenji::Config.option('scale_max')

      links = factors.map do |f|
                fix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
                "#{link.infix(pos, fix)} #{f}x"
              end
      links.join ', '
    end
  end
end

Liquid::Template.register_filter Tenji::Filters
