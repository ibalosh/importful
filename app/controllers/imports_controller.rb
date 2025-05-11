class ImportsController < ApplicationController
  def index
    @imports = Import.where(merchant_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
  end
  def create
    blob = find_uploaded_file_blob
    return if blob.nil? || reject_if_file_too_large(blob)

    import = build_import(blob)

    if import.save
      AffiliatesImportProcessingJob.perform_later(import, current_user.id)
      notice =  "File is processed in the background. You can check the status in the imports page."
      redirect_to import_details_index_path(import), notice:
    else
      redirect_to root_path, alert: "Failed to upload file."
    end
  end

  private

  UPLOADED_FILE_SIZE_LIMIT = 10.megabytes
  UPLOADED_FILE_SIZE_LIMIT_IN_WORDS = ActiveSupport::NumberHelper.number_to_human_size(UPLOADED_FILE_SIZE_LIMIT)

  def build_import(blob)
    Import.new(merchant_id: current_user.id).tap do |import|
      import.file.attach(blob)
    end
  end

  def find_uploaded_file_blob
    ActiveStorage::Blob.find_signed(uploaded_file)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_import_path, alert: "Invalid file upload."
    nil
  end

  def reject_if_file_too_large(blob)
    return false if blob.byte_size <= UPLOADED_FILE_SIZE_LIMIT

    blob.purge
    redirect_to new_import_path, alert: "File is too large. " \
      "Please upload a file smaller than #{UPLOADED_FILE_SIZE_LIMIT_IN_WORDS}."
    true
  end

  def uploaded_file
    params.require(:file)
  end
end
