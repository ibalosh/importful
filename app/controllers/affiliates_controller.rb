class AffiliatesController < ApplicationController
  def index
    @affiliates = Affiliate.order(created_at: :desc).page(params[:page]).per(10)
  end
end
