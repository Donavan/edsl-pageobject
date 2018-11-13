require 'edsl/page_object/javascript/jquery'
require 'edsl/page_object/javascript/prototype'
require 'edsl/page_object/javascript/yui'
require 'edsl/page_object/javascript/angularjs'

module EDSL
  module PageObject
    # Provide hooks into different common Javascript Frameworks.
    # Currently this module only supports jQuery and Prototype but it
    # has the ability for you to plug your own framework into it and
    # therefore have it work with this gem.  You do this by calling the
    # #add_framework method.  The module you provide must implement the
    # necessary methods.  Please look at the jQuery or Prototype
    # implementations to determine the necessary methods
    #
    module JavascriptFrameworkFacade

      class << self
        #
        # Set the framework to use.
        #
        # @param[Symbol] the framework to use.  :jquery, :prototype, :yui,
        # and :angularjs are supported
        #
        def framework=(framework)
          initialize_script_builder unless @builder
          raise unknown_framework(framework) unless @builder[framework]
          @framework = framework
        end

        #
        # Get the framework that will be used
        #
        def framework
          @framework
        end

        #
        # Add a framework and make it available to the system.
        #
        def add_framework(key, value)
          raise invalid_framework unless value.respond_to? :pending_requests
          initialize_script_builder unless @builder
          @builder[key] = value
        end

        #
        # get the javascript to determine number of pending requests
        #
        def pending_requests
          script_builder.pending_requests
        end

        def script_builder
          initialize_script_builder unless @builder
          @builder[@framework]
        end

        private

        def initialize_script_builder
          @builder = {
              :jquery => ::EDSL::PageObject::Javascript::JQuery,
              :prototype => ::EDSL::PageObject::Javascript::Prototype,
              :yui => ::EDSL::PageObject::Javascript::YUI,
              :angularjs => ::EDSL::PageObject::Javascript::AngularJS
          }
        end

        def unknown_framework(framework)
          "You specified the Javascript framework #{framework} and it is unknown to the system"
        end

        def invalid_framework
          "The Javascript framework you provided does not implement the necessary methods"
        end
      end
    end

    module AJAX
      #
      # Wait until there are no pending ajax requests.  This requires you
      # to set the javascript framework in advance.
      #
      # @param [Numeric] the amount of time to wait for the block to return true.
      # @param [String] the message to include with the error if we exceed
      # the timeout duration.
      #
      def wait_for_ajax(timeout = 30, message = nil)
        end_time = ::Time.now + timeout
        until ::Time.now > end_time
          return if browser.execute_script(::EDSL::PageObject::JavascriptFrameworkFacade.pending_requests) == 0
          sleep 0.5
        end
        message = "Timed out waiting for ajax requests to complete" unless message
        raise message
      end
    end
  end
end
