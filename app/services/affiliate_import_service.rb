class AffiliateImportService
  # @param data_processor [CsvDataProcessor] the data processor object
  # @param data_formatter [DataFormatter] the data formatter object
  # @param data_transformer [DataTransformer] the data transformer object
  # @return [Hash] - import statistics
  def initialize(data_processor, data_formatter, data_transformer)
    @data_processor = data_processor
    @data_formatter = data_formatter
    @data_transformer = data_transformer

    reset_result
  end

  # @param import_file [String, StringIO] path to the file
  # @param import_id [Integer] the import id
  # @param merchant_mapping [Hash] the mapping of merchant slug to id
  def call(import_file, import_id, merchant_mapping)
    reset_result
    data_processor.process(import_file) do |chunk|
      formatted_chunk = data_formatter.format(chunk)
      affiliates = data_transformer.transform(formatted_chunk, merchant_mapping)
      bulk_insert(affiliates, import_id, chunk)
    end

    result[:status] = :finished
    result
  rescue DataProcessorError => e
    insert_import_details_record(import_id:, row_number: nil, errors: e.message, payload: nil)
    Rails.logger.error("Failed to process file: #{e.message}")
    result[:status] = :failed
    result
  end

  private

  attr_reader :data_processor, :data_formatter, :data_transformer, :result

  # @param affiliates [Array<Hash>]
  # @param import_id [Integer] the import id
  # @param raw_data [Array<Hash>] the raw data from the CSV file before transformation and formatting
  # @param batch_size [Integer] the size of each batch to insert
  def bulk_insert(affiliates, import_id, raw_data, batch_size: 50)
    affiliates.each_slice(batch_size).with_index do |batch, batch_index|
      ActiveRecord::Base.transaction do
        batch.each_with_index do |affiliate, index|
          errors = insert_affiliate_record(affiliate)
          update_result(processed: errors.empty?)

          if errors.present?
            payload = raw_data[batch_index * batch_size + index]
            row_number = result[:records][:total]
            insert_import_details_record(import_id:, row_number:, errors:, payload:)
          end
        end
      end
    end
  end

  def insert_affiliate_record(affiliate)
    record = Affiliate.new(affiliate)
    record.save
    record.errors.full_messages
  rescue ActiveRecord::ActiveRecordError,
    ArgumentError,
    ActiveModel::UnknownAttributeError => e

    Rails.logger.error("Failed to insert affiliates: #{e.message}")
    [ e.message ]
  end

  def insert_import_details_record(import_id:, row_number:, errors:, payload:)
    ImportDetail.create!(import_id: import_id, row_number:, error_messages: Array.wrap(errors).as_json, payload:)
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("Failed to insert affiliates: #{e.message}")
  end

  def update_result(processed: true)
    result[:records][:total] += 1
    result[:records][:processed] += 1 if processed
    result[:records][:not_processed] += 1 unless processed
  end

  def reset_result
    @result ={
      records: {
        total: 0,
        processed: 0,
        not_processed: 0
      },
      status: :none
    }
  end
end
