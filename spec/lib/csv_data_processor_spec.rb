require "rails_helper"

describe CsvDataProcessor do
  describe "#process" do
    it "parses the CSV file correctly" do
      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        amazon,John,Doe,user@example.com,example.com,1000.50
      CSV
      csv_io = StringIO.new(csv_content)

      expected_content = [
        {
          merchant_slug: "amazon",
          first_name: "John",
          last_name: "Doe",
          email: "user@example.com",
          website_url: "example.com",
          commissions_total: 1000.50
        }
      ]

      described_class.new(csv_io).process do |chunk|
        expect(chunk).to eq(expected_content)
      end
    end

    it "parses the CSV file correctly - different header order" do
      csv_content = <<~CSV
        commissions_total,first_name,last_name,email,website_url,merchant_slug
        1000.50,John,Doe,user@example.com,example.com,merchant
      CSV
      csv_io = StringIO.new(csv_content)

      expected_content = [
        {
          merchant_slug: "merchant",
          first_name: "John",
          last_name: "Doe",
          email: "user@example.com",
          website_url: "example.com",
          commissions_total: 1000.50
        }
      ]

      described_class.new(csv_io).process do |chunk|
        expect(chunk).to eq(expected_content)
      end
    end

    it "parses the CSV file correctly - different separation of headers" do
      csv_content = <<~CSV
        first_name;last_name;email
        John;Doe;user@example.com
      CSV
      csv_io = StringIO.new(csv_content)

      expected_content = [
        {
          first_name: "John",
          last_name: "Doe",
          email: "user@example.com"
        }
      ]

      described_class.new(csv_io).process do |chunk|
        expect(chunk).to eq(expected_content)
      end
    end

    it "parses the CSV file correctly - different separation of headers" do
      csv_content = <<~CSV
        first_name\tlast_name\temail
        John\tDoe\tuser@example.com
      CSV
      csv_io = StringIO.new(csv_content)

      expected_content = [
        {
          first_name: "John",
          last_name: "Doe",
          email: "user@example.com"
        }
      ]

      described_class.new(csv_io).process do |chunk|
        expect(chunk).to eq(expected_content)
      end
    end
  end
end
