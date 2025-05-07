require "rails_helper"

feature "CSV Import", type: :feature, async: false do
  let(:merchant) { create(:merchant) }

  before(:each) do
    visit sessions_new_path
    fill_in "Slug", with: merchant.slug
    fill_in "Password", with: merchant.password
    click_button "Sign In"
  end

  it "User uploads a CSV files and sees it in history" do
    content = <<~CSV
      merchant_slug,first_name,last_name,email,website_url,commissions_total
      merchant-a,John,Doe,john@example.com,https://example.com,100.50
    CSV

    csv_files = [
      create_temp_file(filename: "test1.csv", content:),
      create_temp_file(filename: "test2.csv", content:)
    ]

    csv_files.each do |csv_file|
      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      expect(page).to have_content("File uploaded")
    end

    visit imports_path

    aggregate_failures "verify uploaded files in history" do
      expect(page).to have_content("test1.csv")
      expect(page).to have_content("test2.csv")
    end
  end
end
