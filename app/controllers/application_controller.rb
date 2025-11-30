class ApplicationController < ActionController::Base
  # Devise: allow extra parameters for sign up and account update
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :address, :city, :postal, :province_id ])

    # For account update (edit profile)
    devise_parameter_sanitizer.permit(:account_update, keys: [ :address, :city, :postal, :province_id ])
  end
end
