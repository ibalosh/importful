class MerchantsController < ApplicationController
  before_action :set_merchant, only: %i[edit update]
  def edit; end

  def update
    if @merchant.update(merchant_params)
      redirect_back(fallback_location: root_path)
    else
      alert = "Merchant not updated due to: #{@merchant.errors.full_messages.join(", ")}"
      redirect_back fallback_location: root_path, alert:
    end
  end
  def index
    @pagy, @merchants = pagy(Merchant.order(created_at: :desc))
  end

  private

  def merchant_params
    params.require(:merchant).permit(:slug)
  end

  def set_merchant
    @merchant = Merchant.find(params.expect(:id))
  end
end
