require "rails_helper"
require "stringio"

RSpec.describe AffiliateImportService, type: :service do
  describe "#call" do
    it "raises an error - when missing headers" do
      csv_content = <<~CSV
          first_name,last_name,email,website_url,commissions_total
          John,Doe,user@example.com,example.com,1000
        CSV

      csv_io = StringIO.new(csv_content)
      service = described_class.new(csv_io)

      result = service.call
      aggregate_failures "verify errors" do
        expect(result[:errors].size).to be > 0
        expect(result[:status][:total_rows]).to eq(0)
        expect(result[:status][:processed_rows]).to eq(0)
        expect(result[:status][:failed_to_process_rows]).to eq(0)
      end
    end

    it "inserts valid affiliate into the database" do
      merchant = Merchant.create!(slug: "test-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        test-merchant, John ,Doe, data_transformed@example.com , example.com , 1234.56
      CSV

      csv_io = StringIO.new(csv_content)
      service = AffiliateImportService.new(csv_io)

      expect { service.call }.to change(Affiliate, :count).by(1)

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
      expect { AffiliateImportService.new(csv_io).call }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when there is different amount of data per row" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column
      CSV

      csv_io = StringIO.new(csv_content)
      service = AffiliateImportService.new(csv_io)

      expect { result = service.call }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when there is extra amount of data per row" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column,extra_column
      CSV

      csv_io = StringIO.new(csv_content)

      expect { AffiliateImportService.new(csv_io).call }.to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when data missing" do
      Merchant.create!(slug: "valid-merchant")

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith1@example.com,example.com,750.25,
        valid-merchant,,,john.smith2@example.com,example.com,750.25,
      CSV

      csv_io = StringIO.new(csv_content)

      expect { AffiliateImportService.new(csv_io).call }.to change(Affiliate, :count).by(0)
    end
  end
end
