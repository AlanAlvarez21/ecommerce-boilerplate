class MercadoPagoSdk
  require 'mercadopago'
  
  def initialize
    @access_token = ENV['MP_ACCESS_TOKEN']
  end

  def create_preference(line_items, user_info = {})
    sdk = Mercadopago::SDK.new(@access_token)
    
    payer_info = {
      address: {
        zip_code: user_info[:zip_code] || "",
        street_name: user_info[:street_name] || "",
        street_number: user_info[:street_number] || nil
      },
      email: user_info[:email] || "",
      identification: {
        number: user_info[:identification_number] || "",
        type: user_info[:identification_type] || ""
      }
    }
    
    preference_data = {
      items: line_items,
      back_urls: {
        success: Rails.env.production? ? 'https://yourapp.com/checkout/success' : 'http://localhost:3000/checkout/success',
        failure: Rails.env.production? ? 'https://yourapp.com/checkout/failure' : 'http://localhost:3000/checkout/failure',
        pending: Rails.env.production? ? 'https://yourapp.com/checkout/pending' : 'http://localhost:3000/checkout/pending'
      },
      payer: payer_info,
      external_reference: "ORDER-#{Time.current.to_i}",
      expires: false
    }

    result = sdk.preference.create(preference_data)
    puts result
    
    if result[:status] == 201
      url = Rails.env.production? ? result[:response]['init_point'] : result[:response]['sandbox_init_point']
      puts "=== SUCCESS! URL GENERADA ==="
      puts "URL: #{url}"
      puts "============================="
      return url
    else
      raise "Error creando preferencia: #{result[:response]}"
    end
  end
end