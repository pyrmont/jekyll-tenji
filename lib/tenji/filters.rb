module Tenji
  module Filters
    using Tenji::Refinements

    def format_coords(coords)
      return coords unless coords.is_a?(Array) && coords.length == 3
      degrees = coords[0].to_i
      minutes = coords[1].floor.to_i
      seconds = ((coords[1] - coords[1].floor) * 60).round.to_i
      %Q[#{degrees}&deg; #{minutes}&prime; #{seconds}&Prime;]
    end

    def format_datetime(datetime, fmt = '%e %B %Y')
      return datetime unless datetime.is_a? Time
      datetime.strftime(fmt).strip
    end

    def format_period(date, fmt = '%e %b %Y', sep = '&ndash;')
      return date unless date.is_a? Array
      case date.length
      when 2
        start = date[0].strftime(fmt).strip
        finish = date[1].strftime(fmt).strip
        "#{start}#{sep}#{finish}"
      when 1
        date = date[0].strftime(fmt).strip
        "#{date}"
      else
        raise StandardError
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
