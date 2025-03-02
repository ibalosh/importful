class AffiliateImportService
  # This class accepts array of affiliates which contain merchant slug names.
  #
  # We need to relate this data to merchant records in the database.
  # Only way we can do that is by merchant_id. In order to do that, we will
  # find all the unique merchant names from the affiliates array and find their
  # corresponding merchant_id from the database.
  # find call will return merchant_id, merchant_slug pairs.
  class MerchantFinder
    # @param chunk [Array<Hash>] - array of hashes
    def find(chunk)
      unique_merchants = extract_unique_merchants(chunk)
      find_in_db(unique_merchants)
    end

    private

    # @param records [Array<Hash>] - array of hashes
    def extract_unique_merchants(records)
      records.map { |row| Utils::HashValueFormatter.new.format(
        row, AffiliateImportConfig.fetch(:data_formatting_details))[:merchant_slug]
      }.uniq
    end

    # @param slugs [Array<String>] - array of merchant slug names
    def find_in_db(slugs)
      Merchant.where(slug: slugs).pluck(:slug, :id).to_h
    end
  end
end
