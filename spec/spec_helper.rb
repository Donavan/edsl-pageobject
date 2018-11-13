require 'bundler/setup'
require 'simplecov'
require 'pry'

SimpleCov.start do
  add_filter "/spec/"
end
require 'edsl/page_object'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def watir_container_double
  instance_double('Watir::Container')
end

def watir_browser_double
  instance_double('Watir::Browser')
end

# This allows us to create unique pages for generating accessors in.
def unique_page_object(key, container)
  unique_page_class(key).new(container)
end

def unique_page_class(key)
  Object.const_set("EDSLSpecPage#{key}", Class.new(EDSL::PageObject::Page))
end

# This allows us to create unique pages for generating accessors in.
def unique_section_object(key, container)
  Object.const_set("EDSLSpecSection#{key}", Class.new(EDSL::PageObject::Section)).new(container)
end

def watir_element_double
  ele = double('element')
  allow(ele).to receive(:set).with(anything)
  allow(ele).to receive(:set?).with(no_args).and_return(true)
  allow(ele).to receive(:value).with(no_args).and_return('value')
  allow(ele).to receive(:click).with(no_args)
  allow(ele).to receive(:text).with(no_args).and_return('text')
  allow(ele).to receive(:href).with(no_args).and_return('href')
  ele
end
