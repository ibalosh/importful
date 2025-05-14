class ImportDetailsController < ApplicationController
  def index
    @import = Import.find(import_id)
    @pagy, @import_details = pagy(@import.import_details.order(created_at: :desc))
  end

  private

  def import_id
    params[:import_id]
  end

  def page_param
    params[:page]
  end
end
