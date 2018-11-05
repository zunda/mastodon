Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w(staging production)
  config.excluded_exceptions += ['OpenSSL::SSL::SSLError', 'Mastodon::UnexpectedResponseError', 'HTTP::TimeoutError', 'HTTP::ConnectionError']
end

