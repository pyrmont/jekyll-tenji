module Tenji
  module Filters
    def period_format(date, fmt = '%e %b %Y', sep = '&ndash;')
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
  end
end

Liquid::Template.register_filter Tenji::Filters
