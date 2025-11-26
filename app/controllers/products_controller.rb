class ProductsController < ApplicationController
  # Req 2.1 ✯ - Front page with products
  # Req 2.2 - Navigate by category
  # Req 2.4 - Filter by on_sale, new, recently_updated
  # Req 2.5 - Pagination
  # Req 2.6 ✯ - Search with keyword by category
  def index
    @categories = Category.all

    # Start with all products
    @products = Product.includes(:category).all

    # Filter by category (Req 2.2)
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
      @selected_category = Category.find(params[:category_id])
    end

    # Filter by sale/new/updated (Req 2.4)
    @products = @products.on_sale if params[:on_sale].present?
    @products = @products.new_arrivals if params[:new_arrival].present?
    @products = @products.recently_updated if params[:recently_updated].present?

    # Search functionality (Req 2.6 ✯)
    if params[:q].present?
      @q = @products.ransack(params[:q])
      @products = @q.result(distinct: true)
    end

    # Pagination (Req 2.5)
    @products = @products.page(params[:page]).per(12)
  end

  # Req 2.3 ✯ - Individual product page
  def show
    @product = Product.find(params[:id])
  end
end
