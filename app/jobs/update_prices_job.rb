class UpdatePricesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting price update job"

    begin
      prices = BbvaScraper.obtener_precios

      if prices.present?
        # Cache fresh data
        Rails.cache.write("bbva_prices", prices, expires_in: 1.hour)
        Rails.cache.write("bbva_prices_fallback", prices, expires_in: 1.day)

        Rails.logger.info "Prices updated successfully", {
          prices_count: prices.keys.count,
          updated_at: Time.current
        }
      else
        Rails.logger.warn "No prices returned from scraper"
      end

    rescue StandardError => e
      Rails.logger.error "Price update job failed", {
        error: e.message,
        backtrace: e.backtrace.first(5)
      }

      # Don't fail the job, just log the error
      # The cache fallback will handle serving stale data
    end
  end
end
