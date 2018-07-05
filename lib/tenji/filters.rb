module Tenji
  module Filters
    using Tenji::Refinements

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
    
    def to_srcset(link)
      return link unless link.is_a?(String)

      pos = link.rindex '.'
      factors = 1..Tenji::Config.option('scale_max')

      links = factors.map do |f|
                suffix = (f == 1) ? '' : Tenji::Config.suffix('scale', factor: f)
                "#{link[0...pos] + suffix + link[pos..-1]} #{f}x"
              end
      links.join ', '
    end
  end
end

Liquid::Template.register_filter Tenji::Filters
