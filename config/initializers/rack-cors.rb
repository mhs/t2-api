# Allow cross origin
Rails.application.config.middleware.insert_before Warden::Manager, Rack::Cors do
  allow do
    origins '*'
    resource '*',
            #headers: ['Origin', 'Accept', 'Content-Type', 'X-CSRF-Token'],
            headers: :any,
            methods: [:get, :post, :put, :delete, :options]
  end
end
