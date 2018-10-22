# EDSL-pageobject

This gem implements the page object pattern using EDSL.  It provides a familiar syntax while allowing us to take advantage of the flexibility of EDSL.

If you're familiar with the PageObject gem, this gem has a mostly compatible syntax. While not a drop-in replacement, refactoring PageObject based code is fairly simple.

 * Pages and Sections are classes, not modules.  Instead of including PageObject, you would inherit from Page or Section.
 * Instead of using PageFactory to provide on_page, use EDSL::PageObject::Visitation

This is still very much a work in progress.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'edsl-pageobject'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edsl-pageobject

## Usage
Here's some code from the google_search example.

```ruby
class GoogleSearchPage < EDSL::PageObject::Page
  page_url 'https://www.google.com'

  TEST_HOOKS = CptHook.define_hooks do
    after(:set).call(:search)
  end
  text_field(:query, name: 'q', hooks: TEST_HOOKS)
  button(:search, name: 'btnK')
end
```

Here we define a page class to represent the landing page for google search. Aside from the hooks, this looks like pretty much any ole page object.  Adding a :hooks key to the options hash in the accessor will cause EDSL to wrap our element in a CptHook::Hookable.  See the EDSL docs for more info.


```ruby
class AppBar < EDSL::PageObject::Section
  div(:results_stats, id: 'resultStats')
end

class SearchResult < EDSL::PageObject::Section
  h3(:title, index: 0)
  link(:result_link, index: 0, default_method: :href)
end
```

Here we define a couple classes to represent subsets of the page. Normally calling `result_link` would click the link, but for our pruposes we need the href of the link.  By providing `:href` for `:default_method` key EDSL will return the href instead of clicking the link when we call `result_link`.

Sections in EDSL-pageobject maintain a hierarchical structure and can access their parent via the `parent_container` property.  They also have access to the browser via a `browser` property.

```ruby
class GoogleResultsPage < GoogleSearchPage
  section(:app_bar, AppBar, id: 'appbar')
  sections(:search_results, SearchResult, id: 'search', 
           item: { how: :divs, class: 'g' })
end
```

Now we define a Google results page, using the sections from above. `app-bar` is a single section, while `search_results` is a collection of repeating sections.  

When declaring a collection of sections you tell EDSL how to find the container with the repeating elements as well as how to find the items within it.  In the example above we're saying "for every div with a class of 'g' within the div with the id of 'search' return them as a collection of `SearchResult` objects.

```ruby
module GoogleDemo
  extend EDSL::PageObject::Visitation

  query = ARGV[0] || 'ruby'

  @browser = Watir::Browser.new :chrome, headless: true
  visit(GoogleSearchPage).populate_with( query: query)

  on(GoogleResultsPage) do |page|
    puts "There are #{page.app_bar.results_stats.strip} for #{query}"
    
    result = page.search_results.first
    puts "The first result is titled \"#{result.title}\" and points to #{result.result_link}"
  end
end
```
This is pretty much bog standard PageObject code


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/edsl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Edsl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/edsl/blob/master/CODE_OF_CONDUCT.md).
