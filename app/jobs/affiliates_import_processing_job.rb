# Process a file in background and update the status during the process
class AffiliatesImportProcessingJob < ApplicationJob
  queue_as :default
  def perform(import, merchant)
    filename = import.file.filename.to_s
    import_file_path = ActiveStorage::Blob.service.path_for(import.file.key)

    begin
      Rails.logger.info "CSV processing started for Affiliate Active Storage file with ID: #{import.id}"
      import.update!(status: "processing", filename: filename)

      result = AffiliateImportService.new(
        CsvDataProcessor.new(options: { required_keys: AffiliateImportConfig[:required_headers] }),
        DataFormatter.new(AffiliateImportConfig.fetch(:data_formatting_details)),
        DataTransformer.new(from_key: :merchant_slug, to_key: :merchant_id)
      ).call(import_file_path, import.id, Merchant.slug_id_map_for(merchant))

      records = result.fetch(:records)

      import.update!(
        total_records: records.fetch(:total),
        processed_records: records.fetch(:processed),
        not_processed_records: records.fetch(:not_processed),
        status: result.fetch(:status)
      )
      Rails.logger.info "CSV processing started for Affiliate Active Storage file with ID: #{import.id}"

    rescue StandardError => e
      import.update(status: "failed")
      Rails.logger.error "CSV processing started for Affiliate Active Storage file with ID: #{import.id} - #{e.message}"
      raise e
    end
  end
end
