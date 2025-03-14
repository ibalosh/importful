require "rails_helper"

describe DataTransformer do
  let(:data_transformer) { described_class.new(from_key: :merchant_slug, to_key: :merchant_id) }

  describe "#transform" do
    it "replaces merchant_slug with merchant_id when merchant exists" do
      merchant_mapping = { "existing-merchant" => 1 }

      data = [
        {
          merchant_slug: "existing-merchant",
          first_name: "John",
          last_name: "Doe"
        }
      ]

      transformed_data = data_transformer.transform(data, merchant_mapping)
      record_to_check = transformed_data.first
      expect(record_to_check[:merchant_id]).to eq(1)
    end

    it "assigns -1 when merchant_slug is not found in merchant_mapping" do
      merchant_mapping = {}

      data = [
        {
          merchant_slug: "unknown-merchant",
          first_name: "Jane",
          last_name: "Smith"
        }
      ]

      transformed_data = data_transformer.transform(data, merchant_mapping)
      record_to_check = transformed_data.first

      expect(record_to_check[:merchant_id]).to eq(-1)
      expect(record_to_check).not_to have_key(:merchant_slug)
    end

    it "keeps all other fields unchanged" do
      merchant_mapping = { "valid-merchant" => 2 }

      data = [
        {
          merchant_slug: "valid-merchant",
          first_name: "Michael",
          last_name: "Brown",
          email: "michael@example.com",
          website_url: "http://example.net",
          commissions_total: 750.25
        }
      ]

      transformed_data = data_transformer.transform(data, merchant_mapping)
      record_to_check = transformed_data.first

      aggregate_failures "unchanged fields check" do
        expect(record_to_check[:merchant_id]).to eq(2)
        expect(record_to_check[:first_name]).to eq("Michael")
        expect(record_to_check[:last_name]).to eq("Brown")
        expect(record_to_check[:email]).to eq("michael@example.com")
        expect(record_to_check[:website_url]).to eq("http://example.net")
        expect(record_to_check[:commissions_total]).to eq(750.25)
      end
    end

    it "handles multiple records correctly" do
      merchant_mapping = { "merchant-one" => 101, "merchant-two" => 102 }

      data = [
        {
          merchant_slug: "merchant-one",
          first_name: "Alice"
        },
        {
          merchant_slug: "merchant-two",
          first_name: "Bob"
        }
      ]

      transformed_data = data_transformer.transform(data, merchant_mapping)

      aggregate_failures "multiple records check" do
        expect(transformed_data[0][:merchant_id]).to eq(101)
        expect(transformed_data[0][:first_name]).to eq("Alice")

        expect(transformed_data[1][:merchant_id]).to eq(102)
        expect(transformed_data[1][:first_name]).to eq("Bob")
      end
    end

    it "does not modify empty or nil merchant_slug values" do
      merchant_mapping = { "known-merchant" => 5 }

      data = [
        {
          merchant_slug: nil,
          first_name: "David",
          last_name: "Johnson"
        },
        {
          merchant_slug: "",
          first_name: "Emma",
          last_name: "Williams"
        }
      ]

      transformed_data = data_transformer.transform(data, merchant_mapping)

      aggregate_failures "nil or empty merchant_slug check" do
        expect(transformed_data[0][:merchant_id]).to eq(-1)
        expect(transformed_data[1][:merchant_id]).to eq(-1)
        expect(transformed_data[0]).not_to have_key(:merchant_slug)
        expect(transformed_data[1]).not_to have_key(:merchant_slug)
      end
    end
  end
end
