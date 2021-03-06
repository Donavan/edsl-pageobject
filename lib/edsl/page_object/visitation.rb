require 'page_navigation'

module EDSL
  module PageObject
    module Visitable
      #
      # Set some values that can be used within the class.  This is
      # typically used to provide values that help build dynamic urls in
      # the page_url method
      #
      # @param [Hash] the value to set the params
      #
      def params=(the_params)
        @params = the_params
      end

      #
      # Return the params that exist on this page class
      #
      def params
        @params ||= {}
      end

      def page_url(url)
        define_method("goto") do
          browser.goto page_url_value
        end

        define_method('page_url_value') do
          lookup        = url.kind_of?(Symbol) ? self.send(url) : url
          erb           = ::ERB.new(%Q{#{lookup}})
          merged_params = self.class.instance_variable_get("@merged_params")
          params        = merged_params ? merged_params : self.class.params
          erb.result(binding)
        end
      end
    end

    # Most of this is a semi-direct copy from PageObject::PageFactory
    module Visitation
      include PageNavigation
      #
      # Create and navigate to a page object.  The navigation will only work if the
      # 'page_url' method was call on the page object.
      #
      # @param page_class [Page, String] the page class to create
      #
      # @param params[Hash] values that is passed through to page class available in
      # the @params instance variable.
      #
      # @return [Page] the newly created page
      #
      def visit_page(page_class, params={:using_params => {}}, &block)
        on_page page_class, params, true, &block
      end

      # Support 'visit' for readability of usage
      alias_method :visit, :visit_page

      #
      # Create a page object.
      #
      # @param page_class [Page, String] the page class to create
      #
      # @param params[Hash] values that is passed through to page class available in
      # the @params instance variable.
      # @param visit[Boolean]  a boolean indicating if the page should be visited?  default is false.
      #
      # @return [Page] the newly created page
      #
      def on_page(page_class, params={:using_params => {}}, visit=false, &block)
        page_class = class_from_string(page_class) if page_class.is_a? String
        return super(page_class, params, visit, &block) unless page_class.ancestors.include? Page
        merged = page_class.params.merge(params[:using_params])
        page_class.instance_variable_set("@merged_params", merged) unless merged.empty?
        @@current_page = page_class.new(@browser, visit)
        block.call @@current_page if block
        @@current_page
      end

      # Support 'on' for readability of usage
      alias_method :on, :on_page

      def on_current_page(&block)
        yield @@current_page if block
        @@current_page
      end

      #
      # Create a page object if and only if the current page is the same page to be created
      #
      # @param [PageObject, String]  a class that has included the PageObject module or a string containing the name of the class
      # @param Hash values that is pass through to page class a
      # available in the @params instance variable.
      # @param [block]  an optional block to be called
      # @return [PageObject] the newly created page object
      #
      def if_page(page_class, params={:using_params => {}},&block)
        page_class = class_from_string(page_class) if page_class.is_a? String
        return @@current_page unless @@current_page.class == page_class
        on_page(page_class, params, false, &block)
      end

      # Support 'if' for readability of usage
      alias_method :if, :if_page

      private

      def class_from_string(str)
        str.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      end
    end
  end
end