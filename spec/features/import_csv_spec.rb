require "rails_helper"

feature "CSV Import", type: :feature, async: true do
  let!(:merchant) { create(:merchant, slug: "merchant-a") }
  let(:file_path) { Rails.root.join("spec/fixtures/files/sample.csv") }
  let(:filename) { "sample.csv" }

  it "User uploads a CSV file and sees it in history" do
    visit new_import_path
    attach_file("file", file_path)
    click_button "Upload and Import"

    expect(page).to have_content("File uploaded successfully")

    visit imports_path

    expect(page).to have_content("sample.csv")
    expect(page).to have_content(filename)
  end
end
