class EmailNotificationJob < ApplicationJob
  queue_as :default

  def perform(order_id, notification_type = 'order_confirmation')
    order = Order.find(order_id)
    
    case notification_type
    when 'order_confirmation'
      send_order_confirmation(order)
    when 'payment_received'
      send_payment_confirmation(order)
    when 'order_shipped'
      send_shipping_notification(order)
    else
      Rails.logger.warn "Unknown notification type: #{notification_type}"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Order not found: #{order_id}"
  rescue => e
    Rails.logger.error "Failed to send email notification: #{e.message}"
    raise e
  end

  private

  def send_order_confirmation(order)
    # Here you would integrate with your email service
    # For now, just log the action
    Rails.logger.info "Sending order confirmation email for order #{order.id} to #{order.customer_email}"
    
    # Example: UserMailer.order_confirmation(order).deliver_now
  end

  def send_payment_confirmation(order)
    Rails.logger.info "Sending payment confirmation email for order #{order.id} to #{order.customer_email}"
    
    # Example: UserMailer.payment_received(order).deliver_now
  end

  def send_shipping_notification(order)
    Rails.logger.info "Sending shipping notification email for order #{order.id} to #{order.customer_email}"
    
    # Example: UserMailer.order_shipped(order).deliver_now
  end
end