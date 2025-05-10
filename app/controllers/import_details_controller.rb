class ImportDetailsController < ApplicationController
  def index
    @import = Import.find(import_id)
    @import_details = @import.import_details
  end

  private

  def import_id
    params[:import_id]
  end
end
