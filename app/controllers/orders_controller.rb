class OrdersController < ApplicationController
  before_action :authenticate_user!

  # List all orders for current user
  def index
    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
  end

  # Show one order
  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  # For invoices
  def invoice
    @order = current_user.orders.find(params[:id])
  end
end
