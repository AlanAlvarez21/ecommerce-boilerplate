class Order < ApplicationRecord
    has_many :order_products, dependent: :destroy
    
    validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :total, presence: true, numericality: { greater_than: 0 }
    validates :address, presence: true
end
