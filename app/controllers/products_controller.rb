class ProductsController < ApplicationController
  # CUSTOMER SIDE ONLY — ActiveAdmin untouched.

  def index
    @categories = Category.order(:name)

    # Ransack search object (fixes your error)
    @q = Product.ransack(params[:q])

    # Start with search results
    @products = @q.result.includes(:category)

    # Category filter (Req 2.2)
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
      @selected_category = Category.find(params[:category_id])
    end

    # On Sale filter (Req 2.4)
    if params[:on_sale] == "true"
      @products = @products.where(on_sale: true)
    end

    # New Arrivals filter (Req 2.4)
    if params[:new_arrival] == "true"
      @products = @products.where(new_arrival: true)
    end

    # Recently Updated filter (Req 2.4)
    if params[:recently_updated] == "true"
      @products = @products.where("updated_at >= ?", 7.days.ago)
    end

    # Pagination (Req 2.5)
    @products = @products.page(params[:page]).per(9)
  end

  # Product details page (Req 2.3)
  def show
    @product = Product.find(params[:id])
  end
end
