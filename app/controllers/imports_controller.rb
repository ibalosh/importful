class ImportsController < ApplicationController
  def index
    @imports = Import.where(merchant_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
  end
  def create
    file = ActiveStorage::Blob.find_signed(uploaded_file)
    if file.byte_size > 10.megabytes
      redirect_to new_import_path, alert: "File is too large. Please upload a file smaller than 10MB."
      return
    end

    import = Import.new(merchant_id: current_user.id).tap { |import| import.file.attach(uploaded_file) }

    if import.save
      AffiliatesImportProcessingJob.perform_later(import, current_user.id)
      notice =  "File is processed in the background. You can check the status in the imports page."
      redirect_to import_details_index_path(import), notice:
    else
      redirect_to root_path, alert: "Failed to upload file."
    end
  end

  private
  def uploaded_file
    params.require(:file)
  end
end
