class ImportsController < ApplicationController
  def create
    AffiliateImportService.new(import_file).call
  end

  def import_file
    params.require(:file)
  end
end
