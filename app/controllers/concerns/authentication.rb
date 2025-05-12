# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    before_action :require_logged_in_user
    helper_method :logged_in?
  end

  def current_user
    @current_user ||= Merchant.find_by(id: user_session) if user_session
  end

  def logged_in?
    current_user.present?
  end

  def require_not_logged_in_user
    redirect_to imports_path if logged_in?
  end

  def require_logged_in_user
    redirect_to sign_in_path, alert: "Please sign in to continue" unless logged_in?
  end

  private

  def user_session
    session[:user_id]
  end
end
