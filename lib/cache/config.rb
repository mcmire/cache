
class Cache
  class Config

    # Set the default TTL that keys will live when not specifying a TTL.
    #
    # ttl - Integer in seconds.
    #
    # Example:
    #
    #   cache.config.default_ttl = 120
    #   cache.set('foo', 'val')  # equivalent to set('foo', 'val', 120)
    #
    def default_ttl=(seconds)
      @default_ttl = seconds
    end

    # Get the currently set TTL.
    #
    # Returns an Integer in seconds.
    #
    def default_ttl
      @default_ttl
    end

  end
end
