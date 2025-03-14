class AffiliateImportService
  def initialize(data_processor, data_formatter, data_transformer)
    @data_processor = data_processor
    @data_formatter = data_formatter
    @data_transformer = data_transformer
  end

  # @param file [String] path to the file
  def call(file)
    total_records = 0
    processed_records = 0
    not_processed_records = 0

    data_processor.process(file) do |chunk|
      total_records += chunk.size

      formatted_chunk = data_formatter.format(chunk)
      merchant_mapping = fetch_merchant_mapping(formatted_chunk)

      affiliates = data_transformer.transform(formatted_chunk, merchant_mapping)
      inserted_count = bulk_insert(affiliates)

      processed_records += inserted_count
      not_processed_records += (chunk.size - inserted_count)
    end

    result(total_records:, processed_records:, not_processed_records:, status: :finished)

  rescue DataProcessorError => e
    Rails.logger.error("Failed to parse file: #{e.message}")
    result(total_records:, processed_records:, not_processed_records:, status: :failed, errors: [ e.message ])
  end

  private

  attr_reader :data_processor, :data_formatter, :data_transformer

  def fetch_merchant_mapping(chunk)
    slugs = chunk.map { |entry| entry[:merchant_slug] }.uniq
    Merchant.where(slug: slugs).pluck(:slug, :id).to_h
  end

  # We use insert_all to insert multiple records at once, and make this operation performant
  # We also return number of the inserted records with returning feature supported by SQLite and PostgreSQL
  # https://www.sqlite.org/lang_returning.html
  #
  # Downside of this approach to inserting is that validations and callbacks on records are not called.
  # This can be problematic for error handling for data.
  # @param affiliates [Array<Hash>]
  def bulk_insert(affiliates)
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
