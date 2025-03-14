class MerchantsController < ApplicationController
  def index
    @merchants = Merchant.order(created_at: :desc).page(params[:page]).per(10)
  end
end
