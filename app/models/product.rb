class Product < ApplicationRecord
  has_many_attached :images do |attachable|
      attachable.variant :thumb, resize_to_limit: [ 50, 50 ]
      attachable.variant :medium, resize_to_limit: [ 250, 250 ]
      attachable.variant :large, resize_to_limit: [ 500, 500 ]
  end

  belongs_to :category
  has_many :stocks, dependent: :destroy
  has_many :order_products, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :with_stock, -> { joins(:stocks).where(stocks: { amount: 1.. }).distinct }
  scope :without_stock, -> { left_joins(:stocks).where(stocks: { id: nil }).or(joins(:stocks).where(stocks: { amount: 0 })) }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :search, ->(term) { where("name ILIKE ? OR description ILIKE ?", "%#{term}%", "%#{term}%") }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { joins(:order_products).group(:id).order("COUNT(order_products.id) DESC") }

  # Instance methods
  def in_stock?
    stocks.sum(:amount) > 0
  end

  def total_stock
    stocks.sum(:amount)
  end

  def available_sizes
    stocks.where("amount > 0").pluck(:size).uniq
  end

  def stock_for_size(size)
    stocks.find_by(size: size)&.amount || 0
  end

  def price_with_currency
    "#{price} MXN"
  end

  def main_image
    images.attached? ? images.first : nil
  end

  def can_be_ordered?(size, quantity = 1)
    return false unless active?
    stock_for_size(size) >= quantity
  end

  # Class methods
  def self.low_stock(threshold = 5)
    joins(:stocks).where("stocks.amount <= ?", threshold).distinct
  end

  def self.best_selling(limit = 10)
    joins(:order_products)
      .group(:id)
      .order("SUM(order_products.quantity) DESC")
      .limit(limit)
  end
end
