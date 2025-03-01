class AffiliatesImportProcessingJob < ApplicationJob
  queue_as :default

  def perform(import)
    filename = import.file.filename.to_s
    file_path = ActiveStorage::Blob.service.path_for(import.file.key)

    begin
      Rails.logger.info "Starting CSV processing for Import ID: #{import.id}"
      import.update!(status: "processing", filename: filename)
      result = AffiliateImportService.new(file_path).call
      import.update!(result[:status])
      Rails.logger.info "CSV processing completed for Import ID: #{import.id}"
    rescue StandardError => e
      import.update(status: "failed")
      Rails.logger.error "CSV processing failed for Import ID: #{import.id} - #{e.message}"
      raise e
    end
  end
end
