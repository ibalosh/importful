class AffiliatesController < ApplicationController
  def index
    @affiliates = Affiliate.
      where(merchant_id: current_user.id).
      order(created_at: :desc).
      page(params[:page]).
      per(10)
  end
end
