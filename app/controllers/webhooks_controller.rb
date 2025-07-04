class WebhooksController < ApplicationController
  include ApiResponses
  
  skip_forgery_protection only: [:mercadopago]
  before_action :verify_mercadopago_request, only: [:mercadopago]
  before_action :set_payment_id, only: [:mercadopago]

  def mercadopago
    ProcessPaymentJob.perform_later(@payment_id)
    render_success({ message: "Payment processing initiated" })
  rescue StandardError => e
    Rails.logger.error "Webhook processing failed: #{e.message}", {
      payment_id: @payment_id,
      params: params.to_unsafe_h,
      error: e.message
    }
    render_error("Internal server error", :internal_server_error)
  end

  private

  def verify_mercadopago_request
    # Basic verification - in production, implement signature validation
    unless params[:data]&.dig(:id)
      Rails.logger.warn "Invalid webhook request - missing payment ID", {
        params: params.to_unsafe_h,
        headers: request.headers.env.select { |k,v| k.start_with?('HTTP_') }
      }
      render_error("Invalid request", :bad_request)
      return false
    end
    
    # TODO: Implement proper MercadoPago signature validation
    # https://www.mercadopago.com.ar/developers/es/docs/your-integrations/notifications/webhooks
    true
  end
  
  def set_payment_id
    @payment_id = params[:data][:id]
  end
end