class ImportsController < ApplicationController
  def index
    @imports = Import.order(created_at: :desc).page(params[:page]).per(10)
  end
  def create
    import = Import.new.tap { |import| import.file.attach(uploaded_file) }

    if import.save
      AffiliatesImportProcessingJob.perform_later(import)
      redirect_to root_path, notice: "File uploaded successfully. Processing in background."
    else
      redirect_to root_path, alert: "Failed to upload file."
    end
  end

  def uploaded_file
    params.require(:file)
  end
end
