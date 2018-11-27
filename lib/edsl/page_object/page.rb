require 'erb'
module EDSL
  module PageObject
    DEFAULT_PAGE_READY_LIMIT = 30

    # This class represents an entire page within the browser.
    #
    # Using this base class is not a requirement, however code in some modules may assume that
    # methods in this class are available when they're dealing with pages
    #
    # This allows your object to serve as a proxy for the browser and mirror it's API.
    #
    class Page < ::EDSL::ElementContainer
      include EDSL::PageObject::Population
      include EDSL::PageObject::AJAX
      extend EDSL::PageObject::Visitable

      attr_accessor :page_ready_limit
      alias_method :browser, :root_element

      # Create a new page.
      def initialize(web_browser, visit = false)
        super(web_browser, nil)
        @page_ready_limit = DEFAULT_PAGE_READY_LIMIT
        goto if visit
      end

      # An always safe to call ready function. Subclasses should implement the _ready? method
      # to provide an actual implementation.
      def ready?
        return _ready?
      rescue
        return false
      end

      # Block until the page is ready then yield / return self.
      #
      # If a block is given the page will be yielded to it.
      #
      def when_ready(limit = nil, &block)
        begin
          Watir::Wait.until(limit || page_ready_limit) { _ready? }
        rescue Timeout::Error
          raise Timeout::Error, "Timeout limit #{limit} reached waiting for #{self.class} to be ready"
        end
        yield self if block_given?
        self
      end

      private

      # Subclasses should override this with something that checks the state of the page.
      def _ready?
        true
      end

      def leave_page_using(method, expected_url = nil)
        cur_url = browser.url
        method.call if method.is_a?(Proc)
        send(method) unless method.is_a?(Proc)
        Watir::Wait.until { expected_url ? browser.url == expected_url : browser.url != cur_url }
      end
    end
  end
end
