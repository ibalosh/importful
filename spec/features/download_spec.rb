require "rails_helper"

feature "CSV Import", type: :feature, async: false do
  let(:merchant) { create(:merchant) }

  before(:each) do
    visit sessions_new_path
    fill_in "Slug", with: merchant.slug
    fill_in "Password", with: merchant.password
    click_button "Sign In"
  end

  it "User downloads an imported CSV file" do
    content = <<~CSV
      merchant_slug,first_name,last_name,email,website_url,commissions_total
      merchant-a,John,Doe,john@example.com,https://example.com,100.50
      merchant-a,Jane,Smith,jane@example.com,https://janesblog.com,200.75
    CSV
    filename = "test.csv"
    csv_file = create_temp_file(filename:, content:)

    visit new_import_path
    attach_file("file", csv_file.path)
    click_button "Upload and Import"
    visit imports_path

    download_link = find("a", text: filename)[:href]
    visit download_link

    expect(page.body.strip).to eq(content.strip)
  end
end
