require "rails_helper"

feature "CSV Import and Affiliate Verification", type: :feature, async: false do
  let(:merchant) { create(:merchant, slug: "merchant-a") }

  before(:each) do
    visit sessions_new_path
    fill_in "Slug", with: merchant.slug
    fill_in "Password", with: merchant.password
    click_button "Sign In"
  end

  it "User uploads a CSV file and sees affiliates in the Affiliates page" do
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
    visit affiliates_path

    aggregate_failures "verify affiliates on the page" do
      expect(page).to have_content("John Doe")
      expect(page).to have_content("john@example.com")
      expect(page).to have_content("https://example.com")
    end
  end

  it "User uploads a CSV file and does not see affiliates from other merchant in the Affiliates page" do
    content = <<~CSV
      merchant_slug,first_name,last_name,email,website_url,commissions_total
      merchant-b,John,Doe,john@example.com,https://example.com,100.50
    CSV
    filename = "test.csv"
    csv_file = create_temp_file(filename:, content:)

    visit new_import_path
    attach_file("file", csv_file.path)
    click_button "Upload and Import"
    visit affiliates_path

    aggregate_failures "verify no affiliate on the page" do
      expect(page).not_to have_content("John Doe")
      expect(page).not_to have_content("john@example.com")
      expect(page).not_to have_content("https://example.com")
    end
  end
end
