# frozen_string_literal: true

require 'connection_pool'

class ConnectionPool::UnlimitedTimedStack < ConnectionPool::TimedStack
  def each_connection(&block)
    @mutex.synchronize do
      @que.each(&block)
    end
  end

  def delete(connection)
    @mutex.synchronize do
      @que.delete(connection)
      @created -= 1
    end
  end

  def size
    @mutex.synchronize do
      @que.size
    end
  end

  def try_create(*)
    object = @create_block.call
    @created += 1
    object
  end
end

class ManagedConnectionPool < ConnectionPool
  def initialize(&block)
    super

    @available = ConnectionPool::UnlimitedTimedStack.new(&block)
  end

  def each_connection(&block)
    @available.each_connection(&block)
  end

  def delete(connection)
    @available.delete(connection)
  end

  def size
    @available.size
  end

  def empty?
    size.zero?
  end
end

class RequestPool
  def self.current
    @current ||= RequestPool.new
  end

  class Reaper
    attr_reader :pool, :frequency

    def initialize(pool, frequency)
      @pool      = pool
      @frequency = frequency
    end

    def run
      return unless frequency&.positive?

      Thread.new(frequency, pool) do |t, p|
        loop do
          sleep t
          p.flush
        end
      end
    end
  end

  MAX_IDLE_TIME = 300

  class Connection
    attr_reader :last_used_at, :created_at, :in_use, :dead

    def initialize(site)
      @site         = site
      @http_client  = http_client
      @last_used_at = nil
      @created_at   = Time.now.utc
      @dead         = false
    end

    def use
      @last_used_at = Time.now.utc
      @in_use       = true

      retries = 0

      begin
        yield @http_client
      rescue HTTP::ConnectionError => e
        # It's possible the connection was closed, so let's
        # try re-opening it once

        if retries.positive?
          raise e
        else
          @http_client = http_client
          retry
        end
      rescue StandardError => e
        # If this connection raises errors of any kind, it's
        # better if it gets reaped as soon as possible

        @dead = true
        raise e
      end
    ensure
      @in_use = false
    end

    def seconds_idle
      (Time.now.utc - (@last_used_at || @created_at)).seconds
    end

    def close
      @http_client.close
    end

    private

    def http_client
      Request.http_client.persistent(@site, timeout: MAX_IDLE_TIME)
    end
  end

  def initialize
    @pools  = Concurrent::Map.new
    @reaper = Reaper.new(self, 60)
    @reaper.run
  end

  def with(site, &block)
    connection_pool_for(site).with do |connection|
      connection.use(&block)
    end
  end

  def flush
    idle_pools = []

    @pools.each_pair do |site, pool|
      idle_connections = []

      pool.each_connection do |connection|
        next unless !connection.in_use && (connection.dead || connection.seconds_idle >= MAX_IDLE_TIME)

        connection.close
        idle_connections << connection
      end

      idle_connections.each do |connection|
        pool.delete(connection)
      end

      idle_pools << site if pool.empty?
    end

    idle_pools.each do |site|
      @pools.delete(site)
    end
  end

  def size
    @pools.values.sum(&:size)
  end

  private

  def connection_pool_for(site)
    @pools.fetch_or_store(site) do
      ManagedConnectionPool.new { Connection.new(site) }
    end
  end
end
