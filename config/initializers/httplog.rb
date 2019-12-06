HttpLog.configure do |config|
  config.logger = Rails.logger
  config.color = { color: :yellow }

  config.log_connect   = false
  config.log_request   = true
  config.log_headers   = true
  config.log_data      = false
  config.log_status    = true
  config.log_response  = false
  config.log_benchmark = false
end
