class MercadoPagoSdk
    require "mercadopago"

    def initialize
      @access_token = ENV["MP_ACCESS_TOKEN"]
    end

    def create_preference(line_items)
      mp = Mercadopago::SDK.new(@access_token)

      preference_data = {
        "back_urls" => {
          "success" => Rails.env.production? ? "https://yourapp.com/success" : "http://localhost:3000/success",
          "failure" => Rails.env.production? ? "https://yourapp.com/cancel" : "http://localhost:3000/cancel",
          "pending" => Rails.env.production? ? "https://yourapp.com/pending" : "http://localhost:3000/pending"
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
        "currency_id" => "PEN",
        "items" => line_items,
        "auto_return" => "approved",
        "external_reference" => "order_#{Time.current.to_i}"
      }

      preference = mp.preference.create(preference_data)

      if preference[:status] == 201
        Rails.env.production? ? preference[:response]["init_point"] : preference[:response]["sandbox_init_point"]
      else
        Rails.logger.error "Error creating MercadoPago preference: #{preference[:response]}"
        nil
      end
    end

    # Método helper para formatear items del carrito
    def format_cart_items(cart)
      cart.map do |item|
        {
          "id" => item["id"],
          "title" => item["name"],
          "currency_id" => "PEN",
          "picture_url" => "", # Agregar URL de imagen si la tienes
          "description" => "Tamaño: #{item['size']}",
          "category_id" => "collectibles",
          "quantity" => item["quantity"].to_i,
          "unit_price" => item["price"].to_f
        }
      end
    end
end
