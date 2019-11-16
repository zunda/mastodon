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
      log(request, status)
    rescue Exception => exception
      log(request, status, exception)
      raise exception
    end

    response
  end

  def log(request, status, exception = nil)
    h = {
      request: {
        method: request.method,
        fullpath: request.fullpath,
        header: Hash.new{|h,k| h[k] = Array.new },
        body: request.body.read,
      },
      response: {
        status: status,
      }
    }

    request.env.each do |k, v|
      if k.start_with?('HTTP_')
        h[:request][:header][k] << v
      end
    end

    if exception
      h[:exception] = {
        type: exception&.class&.name,
        message: exception&.message
      }
    end

    Rails.logger.info(h.to_json)
  rescue Exception => exception
    Rails.logger.error(exception.message)
  end
end
