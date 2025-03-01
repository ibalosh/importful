class AffiliateImportService
  class MerchantFinder
    def find(chunk)
      unique_merchants = extract_unique_merchants(chunk)
      find_in_db(unique_merchants)
    end

    private

    def extract_unique_merchants(records)
      records.map { |row| HashValueFormatter.new.format(
        row, AffiliateImport.data_formatting_details)[:merchant_slug]
      }.uniq
    end

    def find_in_db(slugs)
      Merchant.where(slug: slugs).pluck(:slug, :id).to_h
    end
  end

  class ChunkProcessor
    attr_reader :merchant_finder

    def initialize(merchant_finder)
      @merchant_finder = merchant_finder
    end

    def format_chunk(chunk)
      merchants_id_slug_map = merchant_finder.find(chunk)

      chunk.map do |row|
        cleaned_up_row = HashValueFormatter.new.format(row, AffiliateImport.data_formatting_details)
        switch_merchant_slug_to_id(cleaned_up_row, merchants_id_slug_map)
      end
    end

    def switch_merchant_slug_to_id(row, merchant_map)
      row[:merchant_id] = merchant_map[row[:merchant_slug]] || -1
      row.delete(:merchant_slug)
      row
    end
  end

  def initialize(file)
    @data_processor = AffiliateImport.data_processor(file)
    @chunk_processor = ChunkProcessor.new(MerchantFinder.new)
  end

  def call
    total_records = 0
    processed_records = 0
    not_processed_records = 0

    data_processor.process do |chunk|
      total_records += chunk.size
      formatted_affiliates = chunk_processor.format_chunk(chunk)
      inserted_count = insert(formatted_affiliates)

      processed_records += inserted_count
      not_processed_records += (chunk.size - inserted_count)
    end

    result(total_records:, processed_records:, not_processed_records:, status: :success)

  rescue SmarterCSV::Error => e
    result(total_records:, processed_records:, not_processed_records:, status: :success, errors: [ e.message ])
  end

  def insert(affiliates)
    # we use insert_all to insert multiple records at once, and make this operation performant
    # we also return number of the inserted records with returning feature supported by SQLite and PostgreSQL
    #
    # Downside of this approach to inserting is that validations and callbacks on records are not called.
    # This can be problematic for error handling for data.
    Affiliate.insert_all(affiliates, returning: %w[merchant_id]).count

    # in case we can't insert for some reason affiliates, we will log an error
    # if this happens often, we should address the issue
  rescue ActiveRecord::ActiveRecordError,
      ArgumentError,
      ActiveModel::UnknownAttributeError => e

    Rails.logger.error("Failed to insert affiliates: #{e.message}")
    0
  end

  private

  attr_reader :data_processor, :chunk_processor

  def result(total_records:, processed_records:, not_processed_records:, status:, errors: [])
    {
      status: {
        total_records:,
        processed_records:,
        not_processed_records:,
        status:
      },
      errors:
    }
  end
end
