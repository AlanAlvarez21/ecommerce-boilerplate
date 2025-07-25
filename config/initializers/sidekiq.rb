Sidekiq.configure_server do |config|
  config.redis = { 
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }
end

Sidekiq.configure_client do |config|  
  config.redis = { 
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }
end

# Set log level
Sidekiq.logger.level = Logger::INFO

# Configure default job options
Sidekiq.default_job_options = {
  'backtrace' => true,
  'retry' => 3
}