require "rails_helper"

feature "CSV Import", type: :feature, async: false do
  let!(:merchant) { create(:merchant, slug: "merchant-a") }
  let(:file_path) { Rails.root.join("spec/fixtures/files/sample.csv") }
  let(:filename) { "sample.csv" }

  it "User downloads an imported CSV file" do
    visit new_import_path

    # Note: not ideal, since we are loading a fixure file from the filesystem
    # and then we assume merchant in the file is the same as one in test.
    # This can be improved by loading the file content in the test itself.
    attach_file("file", file_path)
    click_button "Upload and Import"

    visit imports_path
    expect(page).to have_content(filename, wait: 5)

    download_link = find("a", text: "sample.csv")[:href]
    visit download_link

    file_content = page.body.strip
    expected_content = File.read(file_path).strip

    expect(file_content).to eq(expected_content)
  end
end
