class CheckoutsController < ApplicationController
  include ApiResponses
  
  def create
    cart_processor = CartProcessor.new(
      cart_data: params[:cart],
      user_info: user_info_params
    )
    
    if cart_processor.valid?
      payment_url = cart_processor.payment_url
      
      if payment_url.present?
        redirect_to payment_url, allow_other_host: true
      else
        redirect_to cart_path, alert: cart_processor.error_message
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_path, alert: cart_processor.error_message }
        format.json { render_error(cart_processor.error_message, :bad_request) }
      end
    end
  end

  def success
    Rails.logger.info "Checkout success", {
      payment_id: params[:payment_id],
      status: params[:status],
      external_reference: params[:external_reference],
      merchant_order_id: params[:merchant_order_id]
    }
    
    render :success
  end

  def failure
    Rails.logger.info "Checkout failure", {
      payment_id: params[:payment_id],
      status: params[:status]
    }
    
    render :failure
  end
  
  def pending
    Rails.logger.info "Checkout pending", {
      payment_id: params[:payment_id],
      status: params[:status]
    }
    
    render :pending
  end
  
  private
  
  def user_info_params
    {
      email: params[:email] || "test@example.com",
      zip_code: params[:zip_code] || "",
      street_name: params[:street_name] || "",
      street_number: params[:street_number],
      identification_number: params[:identification_number] || "",
      identification_type: params[:identification_type] || ""
    }
  end
end