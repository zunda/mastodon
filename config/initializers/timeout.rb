Rack::Timeout::Logger.disable
Rack::Timeout.service_timeout = false

if Rails.env.production?
  Rack::Timeout.service_timeout = ENV.fetch('SERVICE_TIMEOUT') { 90 }.to_i
  Rack::Timeout.wait_timeout = ENV.fetch('WAIT_TIMEOUT') { 30 }.to_i
  Rack::Timeout.wait_overtime = ENV.fetch('WAIT_OVERTIME') { 60 }.to_i
end
