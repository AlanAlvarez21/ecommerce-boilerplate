module PricesHelper
    def self.obtener_precios(asset)
      url = "https://bbv.infosel.com/bancomerindicators/indexV9.aspx"
      response = HTTParty.get(url)
      puts "\nDescargado data del #{asset.upcase}"; 3.times { print "."; sleep(0.5) }; puts " ✅ Descarga completada"

      if response.code == 200
        doc = Nokogiri::HTML(response.body)
        asset_link = asset.downcase == "oro" ? "OroLibertadClosesCV.html" : asset.downcase == "plata" ? "PlataLibertadClosesCV.html" : nil
        return "Asset no soportado" unless asset_link

        asset_data = doc.at_css("a[href*='#{asset_link}']")&.ancestors("div.col-sm-4")

        if asset_data
          compra = asset_data.at_css("div.d-flex > div.border-right .precio-c")&.text&.strip
          venta = asset_data.at_css("div.d-flex > div:not(.border-right) .precio-c")&.text&.strip

          if compra && venta
            # Mostrar precios descargados
            puts "Fecha y hora: #{Time.now}"
            puts "************ OZ #{asset.upcase} LIBERTAD *********************"
            puts "- Compra: #{compra}"
            puts "- Venta: #{venta}"
            puts "**************************************************\n"

            # Actualizar el precio en la base de datos
            coin = Coins.find_by(name: asset.capitalize) # Asegúrate de que el nombre coincida con el caso correcto
            if coin
              # Verificar si los valores obtenidos no son nulos o vacíos antes de actualizar
              if compra.present? && venta.present?
                compra = compra.gsub(/[^\d.]/, "").to_f
                venta = venta.gsub(/[^\d.]/, "").to_f

                coin.update(purchase_price: compra.to_f, selling_price: venta.to_f)
                puts "#{asset.capitalize} - Precios actualizados en la base de datos."
              else
                puts "#{asset.capitalize} - Los precios obtenidos no son válidos."
              end
            else
              puts "#{asset.capitalize} - No se encontró la moneda en la base de datos."
            end
          else
            puts "#{asset.capitalize} - No se pudo encontrar la información de precios en el contenedor."
          end
        else
          puts "#{asset.capitalize} - No se encontró la data de la Onza Libertad de #{asset.capitalize} en la página de BBVA."
        end
      else
        puts "Error al obtener la página: #{response.code}"
      end
    end
end
