class ApplicationController < ActionController::Base
  # Devise: allow extra fields for sign up and account update
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :address, :city, :province_id, :postal
    ])

    # For account update
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :address, :city, :province_id, :postal
    ])
  end
end
