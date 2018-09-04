# frozen_string_literal: true

module Tenji
  module Pageable
    def items_per_page()
      @__items_per_page__
    end

    def paginate(items_per_page)
      return unless items_per_page
      @__items_per_page__ = items_per_page
      self.site.singleton_class.prepend Tenji::Pageable::Site
      self.singleton_class.prepend Tenji::Pageable::Page
    end

    module Site
      def render_regenerated(document, payload)
        return super(document, payload) unless document.is_a? Tenji::Pageable::Page

        document.pages.each do |page|
          super(page, payload)
        end
      end
    end

    module Page
      def pages()
        return @__pages__ if @__pages__
        
        pages = Array.new

        page_nums.each do |page_num|
          page = self.dup
          change_number page, page_num
          change_name page, page_num
          change_dir page, page_num
          change_items page, page_num
          pages << page
        end

        pages.each do |page|
          num = page.data['page_num']
          page.data['page_prev'] = pages[num - 2] if num > 1
          page.data['page_next'] = pages[num] if num < pages.size
        end

        @__pages__ = pages
      end

      def write(dest)
        pages.each do |page|
          page.write(dest)
        end
      end

      private def change_dir(page, num)
        return unless num > 1 && index?
        page.dir = File.join(@dir, num.to_s)
        page.instance_variable_set(:@url, nil)
      end

      private def change_items(page, num)
        page.items = page_items num
      end

      private def change_name(page, num)
        return if num == 1 || index?
        page.basename = "#{basename}-#{num}"
        page.name = page.basename + page.ext
      end

      private def change_number(page, num)
        page.data['page_num'] = num
      end

      private def index?()
        basename == 'index'
      end

      private def page_items(num)
        range = ((num - 1) * items_per_page)...(num * items_per_page)
        items[range]
      end

			private def page_nums
        return 1..1 unless items_per_page
        1..((items.size / items_per_page.to_f).ceil)
    	end
    end
  end
end
