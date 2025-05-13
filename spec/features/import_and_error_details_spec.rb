require "rails_helper"

feature "CSV Import and error details", type: :feature, async: false do
  let(:merchant) { create(:merchant, slug: "merchant-a") }

  before do
    allow_any_instance_of(ImportsController).to receive(:uploaded_file_is_valid).and_return(true)
  end

  def login(username, password)
    visit sessions_new_path
    fill_in "Slug", with: username
    fill_in "Password", with: password
    click_button "Sign In"
  end

  def logout
    visit logout_path
  end

  before(:each) do
    login(merchant.slug, merchant.password)
  end

  context "incorrect csv content" do
    it "missing csv headers in the file" do
      csv_file = create_temp_file(filename: "FILENAME", content: "first_name")

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("missing headers")
    end

    it "file is binary" do
      csv_file = create_temp_binary_file(filename: "FILENAME")

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("please check the file encoding")
    end

    it "missing csv headers in the file" do
      csv_file = create_temp_file(filename: "FILENAME", content: "")

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("file seems to be blank")
    end
  end

  context "csv content is formatted correctly, but contains invalid content" do
    it "duplicate merchants" do
      content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        merchant-a,John,Doe,john@example.com,https://example.com,100.50
        merchant-a,John,Doe,john@example.com,https://example.com,100.50
      CSV
      csv_file = create_temp_file(filename: "FILENAME", content:)

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("Email has already been taken")
    end

    it "for admin no errors when merchant exists, but in another account" do
      merchant = create(:merchant, slug: "merchant-b", role: "admin")

      logout
      login(merchant.slug, merchant.password)

      content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        merchant-a,John,Doe,john@example.com,https://example.com,100.50
      CSV
      csv_file = create_temp_file(filename: "FILENAME", content:)

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      expect(page).not_to have_content("check error details")
    end

    it "merchant exists, but in another account" do
      create(:merchant, slug: "merchant-b", role: "admin")

      content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        merchant-b,John,Doe,john@example.com,https://example.com,100.50
      CSV
      csv_file = create_temp_file(filename: "FILENAME", content:)

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("Merchant must exist")
    end

    it "non existing merchants" do
      content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        merchant-non-existing,John,Doe,john@example.com,https://example.com,100.50
      CSV
      csv_file = create_temp_file(filename: "FILENAME", content:)

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first
      expect(page).to have_content("Merchant must exist")
    end

    it "invalid fields merchants" do
      content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        merchant-a,,,john@example.com,https://example.com,100.50
      CSV
      csv_file = create_temp_file(filename: "FILENAME", content:)

      visit new_import_path
      attach_file("file", csv_file.path)
      click_button "Upload and Import"
      visit imports_path

      click_link "check error details", match: :first

      aggregate_failures do
        expect(page).to have_content("First name can't be blank")
        expect(page).to have_content("Last name can't be blank")
      end
    end
  end
end
