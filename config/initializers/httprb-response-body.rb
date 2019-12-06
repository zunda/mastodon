# frozen_string_literal: true
#
# Monkey patch for
# https://github.com/httprb/http/blob/v3.3.0/lib/http/response/body.rb

module HTTP
  class Response
    class Body
      def readpartial(*args)
        stream!
        chunk = @stream.readpartial(*args)
        if chunk
          chunk.force_encoding(@encoding)
          Rails.logger.debug("Response body: #{__FILE__}:#{__LINE__}")
          Rails.logger.debug(chunk)
        end
        chunk
      end

      def to_s
        return @contents if @contents

        raise StateError, "body is being streamed" unless @streaming.nil?

        begin
          @streaming  = false
          @contents   = String.new("").force_encoding(@encoding)

          while (chunk = @stream.readpartial)
            @contents << chunk.force_encoding(@encoding)
            Rails.logger.debug("Response body: #{__FILE__}:#{__LINE__}")
            Rails.logger.debug(chunk)
            chunk.clear # deallocate string
          end
        rescue
          @contents = nil
          raise
        end

        @contents
      end
    end
  end
end
