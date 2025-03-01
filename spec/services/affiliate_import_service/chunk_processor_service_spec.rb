require 'rails_helper'

describe AffiliateImportService::ChunkProcessor do
  let(:merchant_finder) { instance_double(AffiliateImportService::MerchantFinder) }
  let(:chunk_processor) { described_class.new(merchant_finder) }

  describe "#format_chunk" do
    it "trims unwanted leading and trailing spaces" do
      chunk = [
        {
          merchant_slug: "  slug-name  ",
          first_name: "  first  ",
          last_name: " last ",
          email: "  USER@EXAMPLE.COM  ",
          website_url: " example.com ",
          commissions_total: "1,234.56"
        }
      ]

      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })
      record_to_check = chunk_processor.format_chunk(chunk).first

      aggregate_failures "formatted data check" do
        expect(record_to_check[:merchant_id]).to eq(1)
        expect(record_to_check[:first_name]).to eq("First")
        expect(record_to_check[:last_name]).to eq("Last")
        expect(record_to_check[:email]).to eq("user@example.com")
        expect(record_to_check[:website_url]).to eq("http://example.com")
      end
    end

    it "corrects capitalization" do
      chunk = [
        {
          merchant_slug: "  slug-name  ",
          first_name: "  first  ",
          last_name: " last ",
          email: "  USER@EXAMPLE.COM  ",
          website_url: " EXAMPLE.COM "
        }
      ]

      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })
      record_to_check = chunk_processor.format_chunk(chunk).first

      aggregate_failures "formatted data check" do
        expect(record_to_check[:merchant_id]).to eq(1)
        expect(record_to_check[:first_name]).to eq("First")
        expect(record_to_check[:last_name]).to eq("Last")
        expect(record_to_check[:email]).to eq("user@example.com")
        expect(record_to_check[:website_url]).to eq("http://example.com")
      end
    end

    it "converts numbers to the correct decimal format - single comma" do
      chunk = [ { commissions_total: "1,234.56" } ]

      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })
      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234.56)
    end

    it "converts numbers to the correct decimal format - multiple commas" do
      chunk = [ { commissions_total: "1,234,567.89" } ]

      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })
      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234567.89)
    end

    it "converts numbers to the correct decimal format - remove whitespace" do
      chunk = [ { commissions_total: "1 234 567.89" } ]

      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })
      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234567.89)
    end

    it "ensures URLs include http:// or https:// - no protocol" do
      chunk = [ { website_url: " EXAMPLE.COM " } ]
      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })

      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:website_url]).to eq("http://example.com")
    end

    it "ensures URL include http:// or https:// - preserves protocol" do
      chunk = [ { website_url: "HTTP://EXAMPLE.COM " } ]
      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })

      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:website_url]).to eq("http://example.com")
    end

    it "ensures URL include http:// or https:// - preserves secure protocol" do
      chunk = [ { website_url: "HTTPs://EXAMPLE.COM " } ]
      allow(merchant_finder).to receive(:find).and_return({ "slug-name" => 1 })

      record_to_check = chunk_processor.format_chunk(chunk).first

      expect(record_to_check[:website_url]).to eq("https://example.com")
    end
  end
end
