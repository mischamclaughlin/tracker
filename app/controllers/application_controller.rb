class ApplicationController < ActionController::Base
  include LoggingModule
  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  allow_browser versions: :modern

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username])
  end
end
