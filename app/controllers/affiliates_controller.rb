class AffiliatesController < ApplicationController
  def index
    @pagy, @affiliates = pagy(Affiliate.for_merchant(current_user).order(created_at: :desc))
  end
end
