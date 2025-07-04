class PricesController < ApplicationController
    def index
        @precios = Rails.cache.fetch("bbva_prices", expires_in: 1.hour) do
            fetch_prices_safely
        end
        
        respond_to do |format|
            format.html
            format.json { render json: { prices: @precios, cached_at: Time.current.iso8601 } }
        end
    end
    
    private
    
    def fetch_prices_safely
        BbvaScraper.obtener_precios
    rescue StandardError => e
        Rails.logger.error "Failed to fetch BBVA prices: #{e.message}"
        # Return cached data if available, or empty hash
        Rails.cache.fetch("bbva_prices_fallback", expires_in: 1.day) { {} }
    end
end
