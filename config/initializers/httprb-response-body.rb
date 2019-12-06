# frozen_string_literal: true
#
# Copied from
# https://github.com/httprb/http/blob/v3.3.0/lib/http/response/body.rb
# and edited. Please have a look at the copy right notice at the bottom

require "forwardable"
require "http/client"

module HTTP
  class Response
    # A streamable response body, also easily converted into a string
    class Body
      extend Forwardable
      include Enumerable
      def_delegator :to_s, :empty?

      # The connection object used to make the corresponding request.
      #
      # @return [HTTP::Connection]
      attr_reader :connection

      def initialize(stream, encoding: Encoding::BINARY)
        @stream     = stream
        @connection = stream.is_a?(Inflater) ? stream.connection : stream
        @streaming  = nil
        @contents   = nil
        @encoding   = find_encoding(encoding)
      end

      # (see HTTP::Client#readpartial)
      def readpartial(*args)
        stream!
        chunk = @stream.readpartial(*args)
        if chunk
          chunk.force_encoding(@encoding)
          Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
          Rails.logger.debug(chunk)
        end
        chunk
      end

      # Iterate over the body, allowing it to be enumerable
      def each
        while (chunk = readpartial)
          yield chunk
        end
      end

      # @return [String] eagerly consume the entire body as a string
      def to_s
        return @contents if @contents

        raise StateError, "body is being streamed" unless @streaming.nil?

        begin
          @streaming  = false
          @contents   = String.new("").force_encoding(@encoding)

          while (chunk = @stream.readpartial)
            @contents << chunk.force_encoding(@encoding)
            Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
            Rails.logger.debug(chunk)
            chunk.clear # deallocate string
          end
        rescue
          @contents = nil
          raise
        end

        @contents
      end
      alias to_str to_s

      # Assert that the body is actively being streamed
      def stream!
        raise StateError, "body has already been consumed" if @streaming == false
        @streaming = true
      end

      # Easier to interpret string inspect
      def inspect
        "#<#{self.class}:#{object_id.to_s(16)} @streaming=#{!!@streaming}>"
      end

      private

      # Retrieve encoding by name. If encoding cannot be found, default to binary.
      def find_encoding(encoding)
        Encoding.find encoding
      rescue ArgumentError
        Encoding::BINARY
      end
    end
  end
end

# Copyright (c) 2011-2016 Tony Arcieri, Erik Michaels-Ober, Alexey V. Zapparov, Zachary Anker
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
