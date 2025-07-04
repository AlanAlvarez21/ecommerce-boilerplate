class Product < ApplicationRecord
  has_many_attached :images do |attachable|
      attachable.variant :thumb, resize_to_limit: [ 50, 50 ]
      attachable.variant :medium, resize_to_limit: [ 250, 250 ]
  end

  belongs_to :category
  has_many :stocks
  has_many :order_products
  
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
