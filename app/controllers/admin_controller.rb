class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @orders = Order.where(fulfilled: false).order(created_at: :desc).take(5)
    today_orders = Order.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
    today_revenue = today_orders.sum(:total)
    @quick_stats = {
      sales: today_orders.count,
      revenue: today_revenue > 0 ? today_revenue : nil,
      avg_sale: today_orders.average(:total),
      per_sale: OrderProduct.joins(:order).where(orders: { created_at: Time.current.beginning_of_day..Time.current.end_of_day }).average(:quantity)
    }
    last_7_days = (6.days.ago.to_date..Date.today).to_a
    @orders_by_day = Order.where("created_at >= ?", 7.days.ago.beginning_of_day)
                          .group_by { |order| order.created_at.to_date }
    @revenue_by_day = last_7_days.map do |date|
      day_name = date.strftime("%A")
      orders_for_day = @orders_by_day[date] || []
      revenue = orders_for_day.sum(&:total)
      [ day_name, revenue ]
    end
  end
end
