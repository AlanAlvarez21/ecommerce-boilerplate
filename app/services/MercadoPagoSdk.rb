class MercadoPagoSdk
  require 'mercadopago'
  
  def initialize
    @access_token = ENV['MP_ACCESS_TOKEN']
  end

  def create_preference(line_items)
    mp = Mercadopago::SDK.new(@access_token)
    preference_data = {
      "back_urls" => {
        "success" => Rails.env.production? ? "https://yourapp.com/success" : "http://localhost:3000/success",
        "failure" => Rails.env.production? ? "https://yourapp.com/cancel" : "http://localhost:3000/cancel"
      },
      "payer" => {
        "address" => {
          "zip_code" => "",
          "street_name" => "",
          "street_number" => nil
        },
        "email" => "",
        "identification" => {
          "number" => "", 
          "type" => ""
        }
      },
      "currency_id" => "MXN",
      "items" => line_items
    }
    preference = mp.preference.create(preference_data)
    Rails.env.production? ? preference[:response]["init_point"] : preference[:response]["sandbox_init_point"]
  end
end