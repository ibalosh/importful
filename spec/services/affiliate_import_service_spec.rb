require "rails_helper"

describe AffiliateImportService do
  let(:data_processor) { CsvDataProcessor.new(options: { required_keys: AffiliateImportConfig[:required_headers] }) }
  let(:data_formatter) { DataFormatter.new(AffiliateImportConfig.fetch(:data_formatting_details)) }
  let(:data_transformer) { DataTransformer.new(from_key: :merchant_slug, to_key: :merchant_id) }
  let(:service) { described_class.new(data_processor, data_formatter, data_transformer) }

  describe "#call" do
    it "trims unwanted leading and trailing spaces" do
      csv_content = <<~CSV
          merchant_slug,first_name,last_name,email,website_url,commissions_total
          existing-merchant,  first , last , USER@EXAMPLE.COM , EXAMPLE.COM , 1,234.56
        CSV

      csv_io = StringIO.new(csv_content)

      result = service.call(csv_io)
      aggregate_failures "verify errors" do
        expect(result[:status][:total_records]).to eq(1)
        expect(result[:status][:processed_records]).to eq(0)
        expect(result[:status][:not_processed_records]).to eq(1)
      end
    end

    it "inserts valid affiliate into the database" do
      merchant = Merchant.create!(slug: "test-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        test-merchant, jOhn ,doe, data_transformed@EXAMPLE.com , example.com , 1234.56
      CSV

      csv_io = StringIO.new(csv_content)

      expect { service.call(csv_io) }.to change(Affiliate, :count).by(1)

      affiliate = Affiliate.find_by(email: "data_transformed@example.com")

      aggregate_failures "verify data is in db" do
        expect(affiliate.merchant_id).to eq(merchant.id)
        expect(affiliate.first_name).to eq("John")
        expect(affiliate.last_name).to eq("Doe")
        expect(affiliate.website_url).to eq("http://example.com")
        expect(affiliate.commissions_total).to eq(1234.56)
      end
    end

    it "does not insert affiliates when one merchant is missing in merchants table" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        missing-merchant,Jane,Doe,jane@example.com,example.com,500.00
        valid-merchant,John,Smith,john.smith@example.com,example.org,750.25
      CSV

      csv_io = StringIO.new(csv_content)
      expect { service.call(csv_io) }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when there is different amount of data per row" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column
      CSV

      csv_io = StringIO.new(csv_content)
      expect { service.call(csv_io) }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when there is extra amount of data per row" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column,extra_column
      CSV

      csv_io = StringIO.new(csv_content)
      expect { service.call(csv_io) }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when data missing" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith1@example.com,example.com,750.25,
        valid-merchant,,,john.smith2@example.com,example.com,750.25,
      CSV

      csv_io = StringIO.new(csv_content)
      expect { service.call(csv_io) }.to change(Affiliate, :count).by(0)
    end
  end
end
