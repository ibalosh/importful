class AffiliateImportService
  # We will process chunks of data from the file which contain merchant_slug.
  # Data will preserve it's shape we will only change merchant_slug to merchant_id.
  class ChunkProcessor
    attr_reader :merchant_finder

    # @param merchant_finder [MerchantFinder]
    def initialize(merchant_finder)
      @merchant_finder = merchant_finder
    end

    # @param chunk [Array<Hash>] chunk of data to process
    def format_chunk(chunk)
      merchants_id_slug_map = merchant_finder.find(chunk)

      chunk.map do |row|
        cleaned_up_row = Utils::HashValueFormatter.new.format(row, AffiliateImportConfig.fetch(:data_formatting_details))
        switch_merchant_slug_to_id(cleaned_up_row, merchants_id_slug_map)
      end
    end

    # @param row [Hash], merchant_map [Hash]
    def switch_merchant_slug_to_id(row, merchant_map)
      row[:merchant_id] = merchant_map[row[:merchant_slug]] || -1
      row.delete(:merchant_slug)
      row
    end
  end
end
