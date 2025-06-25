# app/jobs/update_coin_prices_job.rb
class UpdateCoinPricesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    assets = [ "Oro", "Plata" ]
    assets.each do |asset|
      PricesHelper.obtener_precios(asset)
    end
  end
end
