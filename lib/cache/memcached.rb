module Cache::Memcached
  def thread_metal
    ::Thread.current["#{@pid}/#{self.class.name}/#{object_id}/thread_metal"] ||= @metal.clone
  end

  def _get(k)
    thread_metal.get k
  rescue ::Memcached::NotFound
    return nil
  end

  def _get_multi(ks)
    thread_metal.get ks
  end

  def _set(k, v, ttl)
    if _valid_ttl?(ttl)
      thread_metal.set k, v, ttl
    else
      thread_metal.set k, v
    end
  end

  def _cas(k, ttl, &blk)
    if _valid_ttl?(ttl)
      thread_metal.cas k, ttl, &blk
    else
      thread_metal.cas k, &blk
    end
  rescue ::Memcached::NotFound
    return nil
  end

  def _delete(k)
    thread_metal.delete k
  rescue ::Memcached::NotFound
    return nil
  end

  def _flush
    thread_metal.flush
  end

  def _exist?(k)
    thread_metal.get k
    true
  rescue ::Memcached::NotFound
    false
  end

  def _stats
    thread_metal.stats
  end
end
