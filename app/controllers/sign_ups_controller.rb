class SignUpsController < ApplicationController
  skip_before_action :require_logged_in_user
  before_action :require_not_logged_in_user
  def new
    @merchant = Merchant.new
  end

  def create
    @merchant = Merchant.new(merchant_params)

    if @merchant.save
      session[:user_id] = @merchant.id
      redirect_to imports_path, notice: "Signed up successfully"
    else
      flash.now[:alert] = @merchant.errors.full_messages.join(". ")
      render :new, status: :unprocessable_content
    end
  end

  private

  def merchant_params
    params.require(:merchant).permit(:slug, :password, :password_confirmation)
  end
end
