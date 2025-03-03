class AffiliateImportService
  # @param file [String] path to the file
  def initialize(file)
    @data_processor = CsvDataProcessor.new(file, options: { required_keys: AffiliateImportConfig[:required_headers] })
    @affiliates_processor = ChunkProcessor.new(MerchantFinder.new)
  end

  def call
    total_records = 0
    processed_records = 0
    not_processed_records = 0

    data_processor.process do |chunk|
      total_records += chunk.size
      formatted_affiliates = affiliates_processor.format_chunk(chunk)
      inserted_count = insert(formatted_affiliates)

      processed_records += inserted_count
      not_processed_records += (chunk.size - inserted_count)
    end

    result(total_records:, processed_records:, not_processed_records:, status: :finished)

  rescue SmarterCSV::Error => e
    Rails.logger.error("Failed to parse file: #{e.message}")
    result(total_records:, processed_records:, not_processed_records:, status: :failed, errors: [ e.message ])
  end

  private

  attr_reader :data_processor, :affiliates_processor

  # We use insert_all to insert multiple records at once, and make this operation performant
  # We also return number of the inserted records with returning feature supported by SQLite and PostgreSQL
  # https://www.sqlite.org/lang_returning.html
  #
  # Downside of this approach to inserting is that validations and callbacks on records are not called.
  # This can be problematic for error handling for data.
  # @param affiliates [Array<Hash>]
  def insert(affiliates)
    Affiliate.insert_all(affiliates, returning: %w[merchant_id]).count

    # In case we can't insert for some reason affiliates, we will log an error.
    # If this happens often, we should address the issue.
  rescue ActiveRecord::ActiveRecordError,
    ArgumentError,
    ActiveModel::UnknownAttributeError => e

    Rails.logger.error("Failed to insert affiliates: #{e.message}")
    0
  end

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
