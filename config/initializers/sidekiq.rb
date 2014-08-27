require 'sidekiq'
require 'sidekiq-status'

sidekiq_redis = { :namespace => 'sidekiq', url: "redis://localhost:6379" }
Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.options[:concurrency] = 20
#Sidekiq::Logging.initialize_logger(File.join(Rails.root, 'log', 'sidekiq.log'))
