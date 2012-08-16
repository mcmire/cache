require 'cache/config'

class Cache
  class Error < StandardError; end
  class DriverNotFound < Error
    def initialize(client_class)
      @client_class = client_class
    end

    def message
      "The cache gem doesn't support #{@client_class} yet"
    end
  end

  attr_reader :config
  attr_reader :metal

  # For compatibility with Rails 2.x
  attr_accessor :logger

  # Create a new Cache instance by wrapping a client of your choice.
  #
  # Supported memcached clients:
  #
  # * memcached[https://github.com/evan/memcached] (either a Memcached or a Memcached::Rails)
  # * dalli[https://github.com/mperham/dalli] (either a Dalli::Client or an ActiveSupport::Cache::DalliStore)
  # * memcache-client[https://github.com/mperham/memcache-client] (MemCache, the one commonly used by Rails)
  #
  # Supported Redis clients:
  #
  # * redis[https://github.com/ezmobius/redis-rb] (Redis)
  # * redis-namespace[https://github.com/defunkt/redis-namespace] (Redis::Namespace)
  #
  # metal - Either an instance of one of the above classes, or :nothing if you
  #         want to use the Cache API but not actually cache anything.
  #
  # Examples:
  #
  #   # Use Memcached
  #   raw_client = Memcached.new('127.0.0.1:11211')
  #   cache = Cache.new(raw_client)
  #   cache.get(...)
  #   cache.set(...)
  #
  #   # Don't cache anything
  #   cache = Cache.new(:nothing)
  #   cache.get(...)
  #   cache.set(...)
  #
  def initialize(metal)
    @pid = ::Process.pid
    @config = Config.new
    if metal == :nothing
      @metal = nil
      client_class = 'Nothing'
      driver_class = 'Nothing'
    else
      @metal = Cache === metal ? metal.metal : metal
      client_class = @metal.class.to_s
      driver_class = client_class.gsub('::', '')
    end
    filename = client_class.
      gsub(/([a-z])([A-Z]+)/) { [$1.downcase, $2.downcase].join('_') }.
      gsub('::', '_').downcase
    begin
      require "cache/#{filename}"
      extend Cache.const_get(driver_class)
    rescue LoadError, NameError => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace[0..5].join("\n")
      raise DriverNotFound, client_class
    end
  end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  def get(k, ignored_options = nil)
    handle_fork
    _get k
  end

  alias :read :get

  # Get multiple cache entries.
  #
  # Example:
  #     cache.get_multi 'hello', 'privyet'
  def get_multi(*ks)
    handle_fork
    _get_multi ks
  end

  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  def set(k, v, ttl = nil, ignored_options = nil)
    handle_fork
    _set k, v, extract_ttl(ttl)
  end

  alias :write :set

  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  def delete(k, ignored_options = nil)
    handle_fork
    _delete k
  end

  # Flush the cache.
  #
  # Example:
  #     cache.flush
  def flush
    handle_fork
    _flush
  end

  alias :clear :flush

  # Check if something exists.
  #
  # Example:
  #     cache.exist? 'hello'
  def exist?(k, ignored_options = nil)
    handle_fork
    _exist? k
  end
  alias_method :exists?, :exist?

  # Increment a value.
  #
  # Example:
  #     cache.increment 'high-fives'
  def increment(k, amount = 1, ignored_options = nil)
    handle_fork
    new_v = _get(k).to_i + amount
    _set k, new_v, 0
    new_v
  end

  # Decrement a value.
  #
  # Example:
  #     cache.decrement 'high-fives'
  def decrement(k, amount = 1, ignored_options = nil)
    increment k, -amount
  end

  # Try to get a value and if it doesn't exist, set it to the result of the block.
  #
  # Accepts :expires_in for compatibility with Rails.
  #
  # Example:
  #     cache.fetch 'hello' { 'world' }
  def fetch(k, ttl = nil, &blk)
    handle_fork
    _fetch(k, ttl, &blk)
  end

  # Default implementation of #fetch which is overridden in some drivers
  def _fetch(k, ttl, &blk)
    if _exist? k
      _get k
    elsif blk
      v = blk.call
      _set k, v, extract_ttl(ttl)
      v
    end
  end

  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  def cas(k, ttl = nil, &blk)
    handle_fork
    _cas(k, ttl, &blk)
  end

  alias :compare_and_swap :cas

  # Default implementation of #cas which is overridden in some drivers
  def _cas(k, ttl, &blk)
    if blk and _exist?(k)
      old_v = _get k
      new_v = blk.call old_v
      _set k, new_v, extract_ttl(ttl)
      new_v
    end
  end

  # Get stats.
  #
  # Example:
  #     cache.stats
  def stats
    handle_fork
    _stats
  end

  private

  def handle_fork
    if ::Process.pid != @pid
      @pid = ::Process.pid
      after_fork
    end
  end

  def after_fork
    # nothing
  end

  def extract_ttl(ttl)
    case ttl
    when ::Hash
      ttl[:expires_in] || ttl['expires_in'] || ttl[:ttl] || ttl['ttl'] || config.default_ttl
    when ::NilClass
      config.default_ttl
    else
      ttl
    end.to_i
  end
end

