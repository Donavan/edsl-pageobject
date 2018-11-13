RSpec.describe EDSL::PageObject::Page do
  it 'acts as an element container' do
    browser = watir_browser_double
    page = unique_page_object(:spec_ele_cont, browser)
    page.class.send(:text_field, :test_text, id: 'text_field')
    expect(page).to respond_to(:test_text)
  end

  it 'can have a URL' do
    browser = watir_browser_double
    page = unique_page_object(:spec_url, browser)
    page.class.send(:page_url, 'https://google.com')
    expect(page).to respond_to(:page_url_value)
    expect(page.page_url_value).to eq('https://google.com')
  end

  it 'can use ERB to resolve a url using params' do
    browser = watir_browser_double
    page_class = unique_page_class(:spec_erb_url)
    page = page_class.new(browser)


    page.class.send(:page_url, 'https://www.google.com/search?q=<%= url_params[:search_term] %>')
    page_class.instance_variable_set("@merged_params",{ search_term: 'edsl' })
    binding.pry
    expect(page.page_url_value).to eq('https://google.comsearch?q=edsl')
  end
end