class CheckoutController < ApplicationController
    
    def create
        cart = params[:cart]
        
        line_items = cart.map do |item|
            product = Product.find(item["id"])
            product_stock = product.stocks.find { |stock| stock.size == item["size"] }
            if product_stock.amount < item["quantity"].to_i
            render json: { error: "Not enough stock for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left." }, status: 400
            return
            end

            {
            title: item["name"],
            quantity: item["quantity"].to_i,
            size: item["size"],
            product_id: product.id,
            product_stock_id: product_stock.id,
            unit_price: item["price"].to_i
            }
        end

        puts "line_items: #{line_items}"

        payment_url = MercadoPagoSdk.new.create_preference(line_items)
        redirect_to payment_url
    end

    def success
        ender :success
    end

    def cancel
        render :cancel
    end
end