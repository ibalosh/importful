# Process a file in background and update the status during the process
class AffiliatesImportProcessingJob < ApplicationJob
  queue_as :default
  def perform(active_storage_file)
    filename = active_storage_file.file.filename.to_s
    file_path = ActiveStorage::Blob.service.path_for(active_storage_file.file.key)

    begin
      Rails.logger.info "CSV processing started for Affiliate Active Storage file with ID: #{active_storage_file.id}"
      active_storage_file.update!(status: "processing", filename: filename)
      result = AffiliateImportService.new(file_path).call
      result_status = result[:status]

      # we could have just passed the result_status to the update! method,
      # but we are doing it this way to make it clear what is being updated and the error is thrown if the shape
      # of the result is not as expected
      active_storage_file.update!(
        total_records: result_status.fetch(:total_records),
        processed_records: result_status.fetch(:processed_records),
        not_processed_records: result_status.fetch(:not_processed_records),
        status: result_status.fetch(:status)
      )
      Rails.logger.info "CSV processing started for Affiliate Active Storage file with ID: #{active_storage_file.id}"

    # Make sure to log the errors
    rescue StandardError => e
      active_storage_file.update(status: "failed")
      Rails.logger.error "CSV processing started for Affiliate Active Storage file with ID: #{active_storage_file.id} - #{e.message}"
      raise e
    end
  end
end
