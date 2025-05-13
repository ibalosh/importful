require "rails_helper"

feature "CSV Import", type: :feature, async: false do
  let(:merchant) { create(:merchant) }

  before(:each) do
    visit sessions_new_path
    fill_in "Slug", with: merchant.slug
    fill_in "Password", with: merchant.password
    click_button "Sign In"
  end

  it "Rejects file upload if file is too large" do
    uploaded_file_double = instance_double(ActiveStorage::Blob, byte_size: 20.megabytes, purge: true)
    allow(ActiveStorage::Blob).to receive(:find_signed).and_return(uploaded_file_double)
    file_to_upload = create_temp_file(filename: "test.csv", content: "CONTENT")

    visit new_import_path
    attach_file("file", file_to_upload.path)
    click_button "Upload and Import"
    expect(page).to have_content("File is too large")
  end

  it "Uploads a CSV files and sees it in history" do
    allow_any_instance_of(ImportsController).to receive(:uploaded_file_is_valid).and_return(true)

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
