class SessionsController < ApplicationController
  skip_before_action :require_logged_in_user
  before_action :require_not_logged_in_user, except: :destroy
  def new
  end

  def create
    @merchant = Merchant.find_by(slug: merchant_params[:slug])

    if @merchant&.authenticate(merchant_params[:password])
      session[:user_id] = @merchant&.id
      redirect_to imports_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to sign_in_path, notice: "Signed out"
  end

  private

  def merchant_params
    params.permit(:slug, :password)
  end
end
