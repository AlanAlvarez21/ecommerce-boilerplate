class AdminController < ApplicationController
  include ApiResponses
  
  layout "admin"
  before_action :authenticate_admin!
  before_action :ensure_admin_permissions!

  def index
    # Use new Order scopes and methods for better performance
    @recent_orders = Order.pending.recent.limit(5)
    @orders = @recent_orders # For backward compatibility with the view
    
    # Cache expensive calculations
    @quick_stats = Rails.cache.fetch("admin_quick_stats_#{Date.current}", expires_in: 1.hour) do
      calculate_quick_stats
    end
    
    @revenue_by_day = Rails.cache.fetch("admin_revenue_by_day_#{Date.current}", expires_in: 1.hour) do
      Order.revenue_by_day(7)
    end
    
    # Additional useful metrics
    @low_stock_products = Product.low_stock(5).limit(10) rescue []
    @best_selling_products = Product.best_selling(5) rescue []
  end
  
  private
  
  def calculate_quick_stats
    today_start = Time.current.beginning_of_day
    today_end = Time.current.end_of_day
    
    today_orders_count = Order.count_for_period(today_start, today_end)
    today_revenue = Order.revenue_for_period(today_start, today_end)
    today_avg = Order.average_order_value_for_period(today_start, today_end)
    
    # Average items per order today
    per_sale = if today_orders_count > 0
      OrderProduct.joins(:order)
                  .where(orders: { created_at: today_start..today_end })
                  .average(:quantity)
    else
      0
    end
    
    {
      sales: today_orders_count,
      revenue: today_revenue > 0 ? today_revenue : nil,
      avg_sale: today_avg,
      per_sale: per_sale
    }
  end
  
  def ensure_admin_permissions!
    # Add role-based access control if needed
    # For now, just ensure admin is active
    unless current_admin&.email&.present?
      Rails.logger.warn "Unauthorized admin access attempt", {
        admin_id: current_admin&.id,
        ip: request.remote_ip,
        path: request.path
      }
      redirect_to root_path, alert: "Access denied"
    end
  end
end
