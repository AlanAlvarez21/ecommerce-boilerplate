class WebhooksController < ApplicationController
  skip_forgery_protection

  def mercadopago
    payment_id = params[:data][:id]
    sdk = Mercadopago::SDK.new(ENV['MP_ACCESS_TOKEN'])
    payment_response = sdk.payment.get(payment_id)
    payment = payment_response[:response]
    
    if payment['status'] == 'approved'
      create_order(payment)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def create_order(payment)
    address = "#{payment['additional_info']['payer']['address']['street_name']} #{payment['additional_info']['payer']['address']['street_number']}"

    order = Order.create!(
      customer_email: payment['payer']['email'],
      total: payment['transaction_details']['total_paid_amount'],
      address: address,
      fulfilled: false
    )

    line_items = payment["metadata"].values

    line_items.each do |item|
      OrderProduct.create!(
        order: order,
        product_id: item["product_id"],
        quantity: item["quantity"].to_i,
        size: item["size"]
        )
      Stock.find(item["product_stock_id"]).decrement!(:amount, item["quantity"])
    end
  end
end