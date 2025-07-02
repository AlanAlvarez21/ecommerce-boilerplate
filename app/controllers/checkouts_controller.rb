class CheckoutsController < ApplicationController
  def create

     cart_data = params[:cart]
    
    if cart_data.is_a?(ActionController::Parameters)
      cart = cart_data.values
    elsif cart_data.is_a?(Array)
      cart = cart_data
    else
      cart = [cart_data].compact
    end
    
    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = product.stocks.find { |stock| stock.size == item["size"] }
      
      if product_stock.amount < item["quantity"].to_i
        render json: { error: t('checkout.stock_error', product: product.name, size: item["size"], amount: product_stock.amount) }, status: 400
        return
      end

      {
        title: item["name"],
        quantity: item["quantity"].to_i,
        currency_id: "MXN",
        unit_price: item["price"].to_f,
        category_id: "others"
      }
    end

    begin
      user_info = {
        email: params[:email] || "test@example.com",
        zip_code: params[:zip_code] || "",
        street_name: params[:street_name] || "",
        street_number: params[:street_number] || nil,
        identification_number: params[:identification_number] || "",
        identification_type: params[:identification_type] || ""
      }
      
      payment_url = MercadoPagoSdk.new.create_preference(line_items, user_info)
      
      if payment_url.present?
        redirect_to payment_url, allow_other_host: true
      else
        redirect_to cart_path, alert: t('checkout.payment_url_error')
      end
      
    rescue => e
      puts "Error: #{e.message}" # Debug temporal
      redirect_to cart_path, alert: "#{t('checkout.payment_error')}: #{e.message}"
    end
  end

  def success
    payment_id = params[:payment_id]
    status = params[:status]
    external_reference = params[:external_reference]
    merchant_order_id = params[:merchant_order_id]
    
    render :success
  end

  def failure
    render :failure
  end
  
  def pending
    render :pending
  end
end