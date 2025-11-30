class CartController < ApplicationController
  def index
    @cart = session[:cart] || {}
    @items = @cart.map do |product_id, qty|
      product = Product.find_by(id: product_id)
      next unless product
      OpenStruct.new(product: product, quantity: qty)
    end.compact
  end

  def add
    session[:cart] ||= {}
    pid = params[:id].to_s
    session[:cart][pid] = (session[:cart][pid] || 0) + 1
    redirect_back fallback_location: cart_index_path, notice: "Added to cart"
  end

  def update
    session[:cart] ||= {}
    pid = params[:id].to_s
    qty = params[:quantity].to_i
    if qty > 0
      session[:cart][pid] = qty
    else
      session[:cart].delete(pid)
    end
    redirect_to cart_index_path, notice: "Cart updated"
  end

  def remove
    session[:cart] ||= {}
    session[:cart].delete(params[:id].to_s)
    redirect_to cart_index_path, notice: "Removed from cart"
  end
end
