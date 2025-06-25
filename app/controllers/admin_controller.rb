class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @orders = Order.where(fulfilled: false).order(created_at: :desc).take(5)
    @quick_stats = {
      sales: Order.where(created_at: Time.now.midnight..Time.now)&.count,
      revenue: Order.where(created_at: Time.now.midnight..Time.now)&.sum(:total),
      avg_sale: Order.where(created_at: Time.now.midnight..Time.now)&.average(:total),
      per_sale: OrderProduct.joins(:order).where(orders: { created_at: Time.now.midnight..Time.now })&.average(:quantity)
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
