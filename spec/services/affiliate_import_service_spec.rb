require "rails_helper"

describe AffiliateImportService do
  let(:data_processor) { CsvDataProcessor.new(options: { required_keys: AffiliateImportConfig[:required_headers] }) }
  let(:data_formatter) { DataFormatter.new(AffiliateImportConfig.fetch(:data_formatting_details)) }
  let(:data_transformer) { DataTransformer.new(from_key: :merchant_slug, to_key: :merchant_id) }
  let(:import_service) { described_class.new(data_processor, data_formatter, data_transformer) }

  describe "#call" do
    def merchant_mapping(merchant)
      { merchant.slug => merchant.id }
    end

    before(:each) do
      allow(ImportDetail).to receive(:create!)
    end

    it "trims unwanted leading and trailing spaces" do
      merchant = create(:merchant, slug: "existing-merchant")
      fake_import_id = 1
      csv_content = <<~CSV
          merchant_slug,first_name,last_name,email,website_url,commissions_total
          existing-merchant,  first , last , USER@EXAMPLE.COM , EXAMPLE.COM , 1234.56
        CSV

      csv_io = StringIO.new(csv_content)

      result = import_service.call(csv_io, fake_import_id, merchant_mapping(merchant))
      aggregate_failures "verify errors" do
        expect(result.dig(:records, :total)).to eq(1)
        expect(result.dig(:records, :processed)).to eq(1)
        expect(result.dig(:records, :not_processed)).to eq(0)
      end
    end

    it "inserts valid affiliate into the database" do
      merchant = create(:merchant, slug: "test-merchant")
      fake_import_id = 1

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        test-merchant, jOhn ,doe, data_transformed@EXAMPLE.com , example.com , 1234.56
      CSV

      csv_io = StringIO.new(csv_content)

      expect { import_service.call(csv_io, fake_import_id, merchant_mapping(merchant)) }.to change(Affiliate, :count).by(1)

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
      merchant = create(:merchant, slug: "valid-merchant")
      fake_import_id = 1

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        missing-merchant,Jane,Doe,jane@example.com,example.com,500.00
        valid-merchant,John,Smith,john.smith@example.com,example.org,750.25
      CSV

      csv_io = StringIO.new(csv_content)
      expect { import_service.call(csv_io, fake_import_id, merchant_mapping(merchant)) }.
        to change(Affiliate, :count).by(1)
    end

    it "does not insert affiliates when there is different amount of data per row" do
      merchant = create(:merchant, slug: "valid-merchant")
      fake_import_id = 1

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column
      CSV

      csv_io = StringIO.new(csv_content)
      expect { import_service.call(csv_io, fake_import_id, merchant_mapping(merchant)) }.
        to change(Affiliate, :count).by(1)
    end

    it "does not insert affiliates when there is extra amount of data per row" do
      merchant = create(:merchant, slug: "valid-merchant")
      fake_import_id = 1

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith@example.com,example.com,750.25,extra_column,extra_column
      CSV

      csv_io = StringIO.new(csv_content)
      expect { import_service.call(csv_io, fake_import_id, merchant_mapping(merchant)) }.
        to change(Affiliate, :count).by(0)
    end

    it "does not insert affiliates when data missing" do
      merchant = create(:merchant, slug: "valid-merchant")
      fake_import_id = 1

      csv_content = <<~CSV
        merchant_slug,first_name,last_name,email,website_url,commissions_total
        valid-merchant,John,Smith,john.smith1@example.com,example.com,750.25,
        valid-merchant,,,john.smith2@example.com,example.com,750.25,
      CSV

      csv_io = StringIO.new(csv_content)
      expect { import_service.call(csv_io, fake_import_id, merchant_mapping(merchant)) }.
        to change(Affiliate, :count).by(0)
    end
  end
end
