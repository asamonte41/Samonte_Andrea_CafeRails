class DashboardController < ApplicationController
  before_action :authenticate_user!   # require login

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end
end
