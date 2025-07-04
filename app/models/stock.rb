class Stock < ApplicationRecord
  belongs_to :product
  
  validates :size, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
