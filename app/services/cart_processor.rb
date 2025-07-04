class CartProcessor
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attr_accessor :cart_data, :user_info, :errors
  
  def initialize(cart_data:, user_info:)
    @cart_data = normalize_cart_data(cart_data)
    @user_info = user_info
    @errors = []
  end
  
  def valid?
    validate_cart_items
    validate_user_info
    validate_stock_availability
    errors.empty?
  end
  
  def error_message
    errors.join(", ")
  end
  
  def payment_url
    return nil unless valid?
    
    begin
      line_items = build_line_items
      MercadoPagoSdk.new.create_preference(line_items, user_info)
    rescue StandardError => e
      Rails.logger.error "Failed to create payment preference", {
        error: e.message,
        cart_data: cart_data,
        user_info: user_info.except(:identification_number)
      }
      @errors << I18n.t('checkout.payment_error')
      nil
    end
  end
  
  private
  
  def normalize_cart_data(cart_data)
    case cart_data
    when ActionController::Parameters
      cart_data.values
    when Array
      cart_data
    else
      [cart_data].compact
    end
  end
  
  def validate_cart_items
    if cart_data.empty?
      @errors << I18n.t('checkout.empty_cart')
      return
    end
    
    cart_data.each_with_index do |item, index|
      validate_cart_item(item, index)
    end
  end
  
  def validate_cart_item(item, index)
    if item["id"].blank?
      @errors << I18n.t('checkout.invalid_product_id', index: index + 1)
      return
    end
    
    unless Product.exists?(item["id"])
      @errors << I18n.t('checkout.product_not_found', id: item["id"])
      return
    end
    
    quantity = item["quantity"].to_i
    if quantity <= 0
      @errors << I18n.t('checkout.invalid_quantity', index: index + 1)
    end
  end
  
  def validate_user_info
    required_fields = [:email]
    required_fields.each do |field|
      if user_info[field].blank?
        @errors << I18n.t('checkout.missing_field', field: field)
      end
    end
    
    if user_info[:email].present? && !valid_email?(user_info[:email])
      @errors << I18n.t('checkout.invalid_email')
    end
  end
  
  def validate_stock_availability
    cart_data.each do |item|
      next if item["id"].blank?
      
      product = Product.find_by(id: item["id"])
      next unless product
      
      product_stock = product.stocks.find { |stock| stock.size == item["size"] }
      
      if product_stock.nil?
        @errors << I18n.t('checkout.size_not_available', 
                         product: product.name, 
                         size: item["size"])
        next
      end
      
      requested_quantity = item["quantity"].to_i
      if product_stock.amount < requested_quantity
        @errors << I18n.t('checkout.insufficient_stock', 
                         product: product.name, 
                         size: item["size"], 
                         available: product_stock.amount,
                         requested: requested_quantity)
      end
    end
  end
  
  def build_line_items
    cart_data.map do |item|
      product = Product.find(item["id"])
      {
        title: item["name"] || product.name,
        quantity: item["quantity"].to_i,
        currency_id: "MXN",
        unit_price: (item["price"] || product.price).to_f,
        category_id: "others"
      }
    end
  end
  
  def valid_email?(email)
    URI::MailTo::EMAIL_REGEXP.match?(email)
  end
end