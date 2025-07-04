class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order
  
  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :size, presence: true
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  
  # Callbacks
  before_validation :set_unit_price, if: -> { unit_price.blank? && product.present? }
  
  # Instance methods
  def line_total
    quantity * unit_price
  end
  
  def product_name
    product&.name || "Product not found"
  end
  
  def formatted_size
    size.upcase
  end
  
  private
  
  def set_unit_price
    self.unit_price = product.price if product
  end
end
