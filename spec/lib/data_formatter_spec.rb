require "rails_helper"

describe DataFormatter do
  let(:data_formatter) { described_class.new(
    merchant_slug: [ :clean_string ],
    first_name: [ :clean_string, :capitalize_string ],
    last_name: [ :clean_string, :capitalize_string ],
    email: [ :clean_string, :normalize_string ],
    website_url: [ :clean_string, :normalize_url ],
    commissions_total: [ :normalize_number ]
  ) }

  describe "#format" do
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

      record_to_check = data_formatter.format(chunk).first

      aggregate_failures "formatted data check" do
        expect(record_to_check[:merchant_slug]).to eq("slug-name")
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

      record_to_check = data_formatter.format(chunk).first

      aggregate_failures "formatted data check" do
        expect(record_to_check[:first_name]).to eq("First")
        expect(record_to_check[:last_name]).to eq("Last")
        expect(record_to_check[:email]).to eq("user@example.com")
        expect(record_to_check[:website_url]).to eq("http://example.com")
      end
    end

    it "converts numbers to the correct decimal format - single comma" do
      chunk = [ { commissions_total: "1,234.56" } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234.56)
    end

    it "converts numbers to the correct decimal format - multiple commas" do
      chunk = [ { commissions_total: "1,234,567.89" } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234567.89)
    end

    it "converts numbers to the correct decimal format - remove whitespace" do
      chunk = [ { commissions_total: "1 234 567.89" } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:commissions_total]).to eq(1234567.89)
    end

    it "ensures URLs include http:// or https:// - no protocol" do
      chunk = [ { website_url: " EXAMPLE.COM " } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:website_url]).to eq("http://example.com")
    end

    it "ensures URLs include http:// or https:// - preserves protocol" do
      chunk = [ { website_url: "HTTP://EXAMPLE.COM " } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:website_url]).to eq("http://example.com")
    end

    it "ensures URLs include http:// or https:// - preserves secure protocol" do
      chunk = [ { website_url: "HTTPs://EXAMPLE.COM " } ]
      record_to_check = data_formatter.format(chunk).first

      expect(record_to_check[:website_url]).to eq("https://example.com")
    end
  end
end
