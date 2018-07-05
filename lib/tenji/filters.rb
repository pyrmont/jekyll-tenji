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
      density = Tenji::Config.option 'dpi_density'
      
      (1..density).map do |i|
        suffix = (i == 1) ? '' : Tenji::Config.suffix('dpi', factor: i)
        %Q[#{link.insert(pos, suffix)} #{i}x]
      end
    end
  end
end

Liquid::Template.register_filter Tenji::Filters
