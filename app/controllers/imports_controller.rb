class ImportsController < ApplicationController
  def index
    @imports = Import.where(merchant_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
  end
  def create
    import = Import.new(merchant_id: current_user.id).tap { |import| import.file.attach(uploaded_file) }

    if import.save
      AffiliatesImportProcessingJob.perform_later(import, current_user.id)
      notice =  "File uploaded successfully and is processed in background." \
                " You can check the status in the imports page."

      redirect_to new_import_path, notice:
    else
      redirect_to root_path, alert: "Failed to upload file."
    end
  end

  private
  def uploaded_file
    params.require(:file)
  end
end
