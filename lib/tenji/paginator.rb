# frozen_string_literal: true

module Tenji
  class Paginator
    using Tenji::Refinements

    def initialize(source, names, items_per_page, base_url, page_template)
      names.is_a! Hash
      items_per_page.is_maybe! Integer
      base_url.is_a! String
      page_template.is_a! String

      @source = source

      @items_name = names['items']
      @items_per_page = items_per_page
      @items = @source.instance_variable_get(@items_name.to_sym)

      @total_pages = total_pages
      @page_nums = (1..@total_pages).to_a
      @page_num = 1

      @data_name = names['data']
      @data = @source.instance_variable_get(@data_name.to_sym)

      @base_url = base_url
      @page_template = page_template

      @cache = Hash.new
    end

    def number(page)
      page.instance_variable_get(:@__page_num__)
    end

    def page(num = nil)
      num.is_maybe! Integer

      @page_num = num if num && num > 0 && num <= @total_pages
      return @cache[@page_num] if @cache.key? @page_num
      res = @source.dup
      res.instance_variable_set(:@__page_num__, @page_num)
      res.instance_variable_set(@items_name.to_sym, page_of_items)
      res.instance_variable_set(@data_name.to_sym, page_of_data)
      @cache[@page_num] = res
    end

    def pages()
      @page_nums.map { |n| page n }
    end

    private def page_of_data()
      return @data unless @items_per_page
      @data.merge(urls)
    end

    private def page_of_items()
      return @items unless @items_per_page
      max_items = @items.size
      start = (@page_num - 1) * @items_per_page
      finish = (res = @page_num * @items_per_page) < max_items ? res : max_items
      @items[start...finish]
    end

    private def total_pages()
      return 1 unless @items_per_page
      (@items.size / @items_per_page.to_f).ceil
    end

    private def url(num)
      num.is_a! Integer
      return @base_url unless num > 1
      @base_url + @page_template.sub(/#num/, num.to_s)
    end

    private def urls()
      @url_pages ||= @page_nums.map { |n| url(n) }
      { 'url_prev' => @page_num > 1 ? url(@page_num - 1) : nil,
        'url_next' => @page_num < @total_pages ? url(@page_num + 1) : nil,
        'url_pages' => @url_pages }
    end
  end
end
