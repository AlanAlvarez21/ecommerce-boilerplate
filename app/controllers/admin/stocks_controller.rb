class Admin::StocksController < AdminController
  before_action :set_stock, only: %i[ show edit update destroy ]

  # GET /admin/stocks or /admin/stocks.json
  def index
    @admin_stocks = Stock.where(product_id: params[:product_id]).order(created_at: :desc)
  end

  # GET /ad/admin/products/:product_id/stocks/1 or /admin/products/:product_id/stocks/1.json
  def show
  end

  # GET /admin/stocks/new
  def new
    @product = Product.find(params[:product_id])
    @admin_stock = Stock.new
  end

  # GET /admin/stocks/1/edit
  def edit
    @product = Product.find(params[:product_id])
  end

  # POST /admin/stocks or /admin/stocks.json
  def create
    @product = Product.find(params[:product_id])
    @admin_stock = @product.stocks.new(stock_params)

    respond_to do |format|
      if @admin_stock.save
        format.html { redirect_to admin_product_stock_path(@product, @admin_stock), notice: t('admin.stocks.created') }
        format.json { render :show, status: :created, location: admin_product_stock_path(@product, @admin_stock) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/stocks/1 or /admin/stocks/1.json
  def update
    respond_to do |format|
      if @admin_stock.update(stock_params)
        format.html { redirect_to admin_product_stocks_path(@admin_stock.product, @admin_stock), notice: t('admin.stocks.updated') }
        format.json { render :show, status: :ok, location: admin_product_stock_path(@admin_stock.product, @admin_stock) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/stocks/1 or /admin/stocks/1.json
  def destroy
    @admin_stock.destroy!

    respond_to do |format|
      format.html { redirect_to admin_product_stocks_path(@admin_stock.product, @admin_stock), status: :see_other, notice: t('admin.stocks.deleted') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @admin_stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      params.require(:stock).permit(:amount, :size)
    end
end
