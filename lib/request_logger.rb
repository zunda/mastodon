# Add below into config/application.rb:
#
#     config.middleware.use 'RequestLogger'
#
# Copied from https://gist.github.com/jugyo/300e93d6624375fe4ed8674451df4fe0
# and modified
#
# Please DO NOT USE this for production apps.
# This will leak clients' credentials to app logs.
#
class RequestLogger
  def initialize app
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    begin
      response = @app.call(env)
      req_body = request.body.read
      log(request, req_body, response)
    rescue Exception => exception
      log(request, req_body, response, exception)
      raise exception
    end

    response
  end

  def log(request, req_body, response, exception = nil)
    status, res_headers, res_body = response
    h = {
      request: {
        method: request.method,
        fullpath: request.fullpath,
        headers: Hash.new{|h,k| h[k] = Array.new },
      },
      response: {
        status: status,
        headers: res_headers,
      },
    }

    request.env.each do |k, v|
      if k.start_with?('HTTP_')
        h[:request][:headers][k] << v
      end
    end

    if x = parse(req_body)
      h[:request][:body] = x
    end
    if x = parse(res_body.body)
      h[:response][:body] = x
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

  def parse(body)
    unless body.blank?
      begin
        data = JSON.parse(body)
      rescue JSON::ParserError
        body.force_encoding('utf-8')
        data = body.valid_encoding? ? body[0...512] : body.b[0...512].dump
      end
      return data
    else
      return nil
    end
  end
end
