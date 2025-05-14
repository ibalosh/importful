class SessionsController < ApplicationController
  skip_before_action :require_logged_in_user
  before_action :require_not_logged_in_user, except: :destroy
  def new ; end

  def create
    @merchant = Merchant.find_by(slug: merchant_params[:slug])

    if @merchant&.authenticate(merchant_params[:password])
      set_user_session(@merchant&.id)
      redirect_to new_import_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    clear_user_session
    redirect_to sign_in_path, notice: "Signed out"
  end

  private

  def merchant_params
    params.permit(:slug, :password)
  end

  def set_user_session(id)
    session[:user_id] = id
  end

  def clear_user_session
    session[:user_id] = nil
  end
end
