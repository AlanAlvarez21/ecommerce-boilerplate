require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoinsEcommerceApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # set both languages, set spanish :es as default language
    config.i18n.available_locales = [ :en, :es ]
    config.i18n.default_locale = :es
    config.hosts << "pv5g5qjk-3000.usw3.devtunnels.ms"
    
    # Add Rack::Attack middleware
    config.middleware.use Rack::Attack
    
    # Configure timezone
    config.time_zone = 'America/Mexico_City'
    
    # Add app version
    config.version = ENV.fetch('APP_VERSION', '1.0.0')

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
