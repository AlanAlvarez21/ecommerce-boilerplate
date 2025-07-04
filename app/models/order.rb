class Order < ApplicationRecord
    has_many :order_products, dependent: :destroy
    has_many :products, through: :order_products
    
    # Enums for status
    enum :status, {
      pending: 0,
      processing: 1,
      shipped: 2,
      delivered: 3,
      cancelled: 4
    }
    
    # Validations
    validates :customer_email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, message: "is not a valid email address" }
    validates :total, presence: true, numericality: { greater_than: 0 }
    validates :address, presence: true
    validates :status, presence: true
    validates :payment_id, uniqueness: true, allow_nil: true
    
    # Scopes
    scope :today, -> { where(created_at: Date.current.all_day) }
    scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
    scope :this_month, -> { where(created_at: 1.month.ago..Time.current) }
    scope :by_email, ->(email) { where(customer_email: email) }
    scope :recent, -> { order(created_at: :desc) }
    scope :with_payment_id, -> { where.not(payment_id: nil) }
    
    # Class methods for analytics
    def self.revenue_for_period(start_date, end_date)
      delivered.where(created_at: start_date..end_date).sum(:total)
    end
    
    def self.count_for_period(start_date, end_date)
      where(created_at: start_date..end_date).count
    end
    
    def self.average_order_value_for_period(start_date, end_date)
      where(created_at: start_date..end_date).average(:total)
    end
    
    def self.revenue_by_day(days_back = 7)
      end_date = Date.current
      start_date = (days_back - 1).days.ago.to_date
      
      (start_date..end_date).each_with_object({}) do |date, hash|
        revenue = delivered.where(created_at: date.all_day).sum(:total)
        hash[date] = revenue
      end
    end
    
    # Instance methods
    def fulfilled?
      delivered?
    end
    
    def can_be_cancelled?
      pending? || processing?
    end
    
    def total_items
      order_products.sum(:quantity)
    end
    
    def total_with_currency
      "#{total} MXN"
    end
    
    def formatted_total
      "$#{total}"
    end
    
    # Callbacks
    before_save :normalize_email
    after_create :generate_payment_id_if_blank
    
    private
    
    def normalize_email
      self.customer_email = customer_email.downcase if customer_email.present?
    end
    
    def generate_payment_id_if_blank
      if payment_id.blank?
        self.update_column(:payment_id, "ORD-#{SecureRandom.hex(8).upcase}")
      end
    end
end
