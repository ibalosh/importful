require "rails_helper"

feature "CSV Import and Affiliate Verification", type: :feature, async: false do
  let!(:merchant) { create(:merchant, slug: "merchant-a") }
  let(:file_path) { Rails.root.join("spec/fixtures/files/sample.csv") }
  let(:filename) { "sample.csv" }

  it "User uploads a CSV file and sees affiliates in the Affiliates page" do
    visit new_import_path
    attach_file("file", file_path)
    click_button "Upload and Import"

    expect(page).to have_content("File uploaded successfully", wait: 5)

    visit affiliates_path

    expect(page).to have_content("John Doe")
    expect(page).to have_content("john@example.com")
    expect(page).to have_content("https://example.com")
  end
end
