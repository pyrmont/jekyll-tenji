# frozen_string_literal: true

module Tenji
  class Paginator 
    using Tenji::Refinements

    def initialize(source, items_name, items_per_page, base_url)
      items_name.is_a! String
      base_url.is_a! String

      @source = source
      @items = @source.instance_variable_get("@#{items_name}")
      @items_name = items_name
      @items_per_page = items_per_page
      @total_pages = (items_per_page) ? (@items.size / items_per_page.to_f).ceil : 1
      @page_num = 1
      @base_url = base_url
      @cache = Hash.new
    end

    def number(page)
      page.instance_variable_get(:@__page_num__)
    end

    def page(page_num = nil)
      @page_num = page_num if page_num && page_num > 0 && page_num <= @total_pages 
      return @cache[@page_num] if @cache.key? @page_num
      res = @source.dup
      res.instance_variable_set("@#{@items_name}".to_sym, page_of_items)
      res.instance_variable_set(:@__page_num__, @page_num)
      @cache[@page_num] = res
    end

    def pages()
      (1..@total_pages).to_a.map do |num|
        page num
      end
    end

    def urls(page_num)
      url_prev = page_num > 1 ? url(page_num - 1) : nil
      url_next = page_num < @total_pages ? url(page_num + 1) : nil
      { 'url_prev' => url_prev, 'url_next' => url_next }
    end

    private def page_of_items()
      return @items unless @items_per_page
      start = (@page_num - 1) * @items_per_page
      finish = (res = @page_num * @items_per_page) < @items.size ? res : @items.size
      @items[start...finish]
    end

    private def url(page_num)
      @base_url + 'page-' + page_num.to_s + '/'
    end
  end
end
