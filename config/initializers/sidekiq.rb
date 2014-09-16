require 'sidekiq'
require 'sidekiq-status'

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'sidekiq', url: "redis://localhost:6379" }

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end

end

Sidekiq.configure_client do |config|
  host = Rails.env.production? ? ENV['REDIS_HOST'] : "localhost"
  config.redis = { :namespace => 'sidekiq', url: "redis://#{host}:6379" }

  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end