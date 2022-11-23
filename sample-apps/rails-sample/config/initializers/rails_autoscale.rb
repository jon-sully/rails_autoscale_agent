return unless defined?(Judoscale)

Judoscale.configure do |config|
  # Open https://rails-autoscale-adapter-mock.requestcatcher.com in a browser to monitor requests
  config.api_base_url = ENV["JUDOSCALE_URL"] || "https://rails-autoscale-adapter-mock.requestcatcher.com"
end
