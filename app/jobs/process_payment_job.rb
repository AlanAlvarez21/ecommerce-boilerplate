class ProcessPaymentJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(payment_id)
    Rails.logger.info "Processing payment", { payment_id: payment_id }

    payment_data = fetch_payment_data(payment_id)

    if payment_data && payment_data["status"] == "approved"
      order = PaymentProcessor.process_approved_payment(payment_data)

      if order
        Rails.logger.info "Payment processed successfully", {
          payment_id: payment_id,
          order_id: order.id
        }
        # TODO: Send confirmation email
        # OrderConfirmationMailer.with(order: order).confirmation_email.deliver_now
      else
        Rails.logger.error "Failed to process approved payment", {
          payment_id: payment_id
        }
      end
    else
      Rails.logger.info "Payment not approved or not found", {
        payment_id: payment_id,
        status: payment_data&.dig("status")
      }
    end
  end

  private

  def fetch_payment_data(payment_id)
    sdk = Mercadopago::SDK.new(ENV["MP_ACCESS_TOKEN"])
    payment_response = sdk.payment.get(payment_id)
    payment_response[:response]
  rescue StandardError => e
    Rails.logger.error "Failed to fetch payment data", {
      payment_id: payment_id,
      error: e.message
    }
    nil
  end
end
