RSpec.describe EDSL::PageObject do
  it 'extends the DSL to include section objects' do
    page = unique_page_object(:section_dsl, nil)
    expect(page.class).to respond_to(:section)
  end

  it 'extends the DSL to include collections of section objects' do
    page = unique_page_object(:sections_dsl, nil)
    expect(page.class).to respond_to(:sections)
  end
end
