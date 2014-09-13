require 'sidekiq'
require 'sidekiq-status'

Sidekiq.configure_server do |config|
  pool_size = Sidekiq.options[:concurrency] + 2
  config.redis = { :namespace => 'sidekiq', url: "redis://localhost:6379", :size => pool_size }

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end

  if defined?(ActiveRecord::Base)
    config = Rails.application.config.database_configuration[Rails.env]
    config['adapter'] = 'postgresql'
    config['pool']    = pool_size
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    ActiveRecord::Base.establish_connection(config)
  end
end

Sidekiq.configure_client do |config|
  host = Rails.env.production? ? ENV['REDIS_HOST'] : "localhost"
  config.redis = { :namespace => 'sidekiq', url: "redis://#{host}:6379" }

  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end