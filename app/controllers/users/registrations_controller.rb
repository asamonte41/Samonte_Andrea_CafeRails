class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :address, :city, :postal, :province_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :address, :city, :postal, :province_id ])
  end
end
