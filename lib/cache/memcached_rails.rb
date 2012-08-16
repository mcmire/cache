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
      thread_metal.cas k, extract_ttl(ttl), &blk
    end

    def _delete(k)
      thread_metal.delete k
    end
  end
end
