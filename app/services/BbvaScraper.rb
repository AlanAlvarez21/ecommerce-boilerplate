require "httparty"
require "nokogiri"

class BbvaScraper
  def self.obtener_precios
    precios = []
    assets = [ "Oro", "Plata" ]

    url = "https://bbv.infosel.com/bancomerindicators/indexV9.aspx"
    response = HTTParty.get(url)

    if response.code == 200
      doc = Nokogiri::HTML(response.body)

      assets.each do |asset|
        asset_link = asset.downcase == "oro" ? "OroLibertadClosesCV.html" : "PlataLibertadClosesCV.html"
        asset_data = doc.at_css("a[href*='#{asset_link}']")&.ancestors("div.col-sm-4")

        if asset_data
          compra = asset_data.at_css("div.d-flex > div.border-right .precio-c")&.text&.strip
          venta = asset_data.at_css("div.d-flex > div:not(.border-right) .precio-c")&.text&.strip
          precios << { nombre: asset, compra: compra, venta: venta } if compra && venta
        end
      end
    end

    precios
  end
end
