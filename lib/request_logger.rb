# Add below into config/application.rb:
#
#     config.middleware.use 'RequestLogger'
#
# Copied from https://gist.github.com/jugyo/300e93d6624375fe4ed8674451df4fe0
# and modified
class RequestLogger
  def initialize app
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    begin
      status, _, _ = response = @app.call(env)
      req_body = request.body.read
      log(request, req_body, status)
    rescue Exception => exception
      log(request, req_body, status, exception)
      raise exception
    end

    response
  end

  def log(request, req_body, status, exception = nil)
    h = {
      request: {
        method: request.method,
        fullpath: request.fullpath,
        headers: Hash.new{|h,k| h[k] = Array.new },
      },
      response: {
        status: status,
      },
    }

    request.env.each do |k, v|
      if k.start_with?('HTTP_')
        h[:request][:headers][k] << v
      end
    end

    unless req_body.blank?
      begin
        req_body = JSON.parse(req_body)
      rescue JSON::ParserError
      end
      h[:request][:body] = req_body
    end

    if exception
      h[:exception] = {
        type: exception.class.name,
        message: exception.message,
      } 
    end

    Rails.logger.info(h.to_json)
  rescue Exception => exception
    Rails.logger.error(exception.message)
  end
end
