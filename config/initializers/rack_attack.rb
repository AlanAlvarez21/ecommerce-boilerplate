# config/initializers/rack_attack.rb

class Rack::Attack
  # Configuration
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  
  # Allow local traffic
  safelist('allow-localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1'
  end
  
  # Allow health checks
  safelist('allow-health-checks') do |req|
    req.path.start_with?('/health')
  end
  
  # Throttle general requests by IP
  throttle('general/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end
  
  # Throttle API requests more strictly
  throttle('api/ip', limit: 100, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/api/')
  end
  
  # Throttle webhook requests
  throttle('webhooks/ip', limit: 50, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/webhooks')
  end
  
  # Throttle login attempts
  throttle('login/email', limit: 5, period: 1.hour) do |req|
    if req.path == '/admins/sign_in' && req.post?
      # Get email from params (this is simplified)
      req.params.dig('admin', 'email')&.downcase
    end
  end
  
  throttle('login/ip', limit: 10, period: 1.hour) do |req|
    if req.path == '/admins/sign_in' && req.post?
      req.ip
    end
  end
  
  # Block specific IPs (example)
  # blocklist('block-bad-actors') do |req|
  #   # Block requests from known bad IPs
  #   %w[192.168.1.100].include?(req.ip)
  # end
  
  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [
      429, # status
      {
        'Content-Type' => 'application/json',
        'Retry-After' => '60'
      },
      [JSON.generate({
        error: 'Rate limit exceeded',
        message: 'Too many requests. Please try again later.',
        retry_after: 60
      })]
    ]
  end
  
  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |env|
    [
      403, # status
      { 'Content-Type' => 'application/json' },
      [JSON.generate({
        error: 'Forbidden',
        message: 'Your request has been blocked.'
      })]
    ]
  end
end