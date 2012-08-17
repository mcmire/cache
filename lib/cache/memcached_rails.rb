require 'cache/memcached'

module Cache::MemcachedRails
  def self.extended(base)
    base.extend Cache::Memcached
    base.extend Override
  end

  module Override
    def _exist?(k)
      thread_metal.exist? k
    end

    def _get(k)
      thread_metal.get k
    end

    def _get_multi(ks)
      thread_metal.get_multi ks
    end

    def _cas(k, ttl, &blk)
      if _valid_ttl?(ttl)
        thread_metal.cas k, ttl, &blk
      else
        thread_metal.cas k, &blk
      end
    end

    def _delete(k)
      thread_metal.delete k
    end
  end
end
