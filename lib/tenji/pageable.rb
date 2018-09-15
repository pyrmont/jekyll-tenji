# frozen_string_literal: true

module Tenji

  # A module for enabling simple pagination
  #
  # {Tenji::Pageable} is a module that `Jekyll::Page` objects (or objects that
  # inherit from them) can include to offer simple pagination. A class that 
  # includes the module needs to implement two methods: `#items` and `#items=`.
  # These methods get and set the items that are the basis on which pagination
  # should occur.
  #
  # In Tenji, for example, the {Tenji::ListPage} paginates on the basis of the 
  # galleries that it displays. Accordingly, its methods get and set the
  # the galleries.
  #
  # In addition to implementing these methods, a class needs to call 
  # `#paginate` at some point before Jekyll's rendering step. This will set an
  # instance variable specifying the maximum nunber of items to display per
  # page. A class will typically call the method during initialisation.
  #
  # {Tenji::Pageable} implements pagination by taking advantage of the 
  # inheritance properties of Ruby classes. A module is added to the singleton
  # class of the `Jekyll::Site` object and another module to the singleton
  # class of the object to be paginated. Both these modules are added to the
  # beginning of the ancestor chain by using `Module#prepend`. Calls to certain
  # methods used in the rendering process are then intercepted and duplicate
  # objects created for each paginated page.
  #
  # Although this is assumed to be less performant than Jekyll's approach of
  # using a paginator object, it simplifies the way templates need to be written
  # and is more logically consistent with the notion of `Jekyll::Page` objects 
  # representing 'pages' on the website.
  #
  # @since 0.1.0
  # @api private
  module Pageable

    # Return the maximum number of items per page
    #
    # @return [Integer, nil] the number (nil will be returned if the number has
    #   not been set)
    #
    # @since 0.1.0
    # @api private
    def items_per_page()
      @__items_per_page__
    end

    # Set the maximum number of items per page
    #
    # @param items_per_page [Integer] the maximum number of items per page
    #
    # @since 0.1.0
    # @api private
    def paginate(items_per_page)
      return unless items_per_page
      @__items_per_page__ = items_per_page
      self.site.singleton_class.prepend Tenji::Pageable::Site
      self.singleton_class.prepend Tenji::Pageable::Page
    end

    # A module to patch a `Jekyll::Site` object's singleton class
    #
    # @since 0.1.0
    # @api private
    module Site

      # Render the document
      #
      # @param document [Jekyll::Page] the document to be rendered
      # @param payload [Hash] the site payload
      #
      # @since 0.1.0
      # @api private
      def render_regenerated(document, payload)
        return super(document, payload) unless document.is_a? Tenji::Pageable::Page

        document.pages.each do |page|
          super(page, payload)
        end
      end
    end

    # A module to patch a {Tenji::Page} object's singleton class
    #
    # @since 0.1.0
    # @api private
    module Page

      # Return the pages of the document
      #
      # This caches the result in an instance variable.
      #
      # @return [Array<Tenji::Page>] the pages
      #
      # @since 0.1.0
      # @api private
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

      # Write the page
      #
      # @param dest [String] the destination to which the page will be written
      #
      # @since 0.1.0
      # @api private
      def write(dest)
        pages.each do |page|
          page.write(dest)
        end
      end

      # Append a numeral directory to the directory path
      #
      # Documents that represent index pages have pages after the first
      # added to directories with numerals (eg. `.../gallery/2/`). This
      # updates the `@dir` instance variable.
      #
      # @param page [Jekyll::Page] the page
      # @param num [Integer] the number of the page
      #
      # @since 0.1.0
      # @api private
      private def change_dir(page, num)
        return unless num > 1 && index?
        page.dir = File.join(@dir, num.to_s)
        page.instance_variable_set(:@url, nil)
      end

      # Change the number of items held by the page
      #
      # @param page [Jekyll::Page] the page
      # @param num [Integer] the number of the page
      #
      # @since 0.1.0
      # @api private
      private def change_items(page, num)
        page.items = page_items num
      end

      # Change the basename of the page
      #
      # @param page [Jekyll::Page] the page
      # @param num [Integrr] the number of the page
      #
      # @since 0.1.0
      # @api private
      private def change_name(page, num)
        return if num == 1 || index?
        page.basename = "#{basename}-#{num}"
        page.name = page.basename + page.ext
      end

      # Change the page number of the page
      #
      # @param page [Jekyll::Page] the page
      # @param num [Integer] the number of the page
      #
      # @since 0.1.0
      # @api private
      private def change_number(page, num)
        page.data['page_num'] = num
      end

      # Return whether this page is an index page or not
      #
      # @return [Boolean] whether this is an index page
      #
      # @since 0.1.0
      # @api private
      private def index?()
        basename == 'index'
      end

      # Return the items for the given page
      #
      # @param num [Integer] the number of the page
      #
      # @return [Array<Jekyll::Page>] the items for this page
      #
      # @since 0.1.0
      # @api private
      private def page_items(num)
        range = ((num - 1) * items_per_page)...(num * items_per_page)
        items[range]
      end
      
      # Return the total number of pages for this document
      #
      # @return [Range] the total number of pages
      #
      # @since 0.1.0
      # @api private
      private def page_nums
        return 1..1 unless items_per_page
        1..((items.size / items_per_page.to_f).ceil)
    	end
    end
  end
end
