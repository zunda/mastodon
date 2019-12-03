HttpLog.configure do |config|
  config.logger = Rails.logger
  config.severity = 1
  config.color = { color: :yellow }
  config.log_headers = true
end
