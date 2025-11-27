class ProductsController < ApplicationController
  # Public storefront — no admin changes

  def index
    @categories = Category.all

    # Base relation
    @products = Product.all

    # Category filter (Req 2.2)
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    # Search filter (Req 2.6)
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @products = @products.where(
        "name ILIKE ? OR description ILIKE ?", keyword, keyword
      )
    end

    # Pagination (Req 2.5)
    @products = @products.page(params[:page]).per(9)
  end

  # Individual product page (Req 2.3)
  def show
    @product = Product.find(params[:id])
  end

  # Filter pages -------------------------

  # /products/on_sale
  def on_sale
    @categories = Category.all
    @products = Product.on_sale.page(params[:page]).per(9)
    render :index
  end

  # /products/new_arrivals
  def new_arrivals
    @categories = Category.all
    @products = Product.new_arrivals.page(params[:page]).per(9)
    render :index
  end

  # /products/recently_updated
  def recently_updated
    @categories = Category.all
    @products = Product.recently_updated.page(params[:page]).per(9)
    render :index
  end

  # /products/search
  def search
    @categories = Category.all
    keyword = "%#{params[:q]}%"
    @products = Product.where("name ILIKE ? OR description ILIKE ?", keyword, keyword)
                       .page(params[:page])
                       .per(9)

    render :index
  end
end
