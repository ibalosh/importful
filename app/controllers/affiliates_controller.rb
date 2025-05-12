class AffiliatesController < ApplicationController
  def index
    @affiliates = Affiliate.
      for_merchant(current_user).
      order(created_at: :desc).
      page(params[:page]).
      per(10)
  end
end
