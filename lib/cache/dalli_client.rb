module Cache::DalliClient
  def after_fork
    @metal.close
  end

  def _get(k)
    @metal.get k
  end

  def _get_multi(ks)
    @metal.get_multi ks
  end

  def _set(k, v, ttl)
    @metal.set k, v, ttl
  end

  def _fetch(k, ttl, &blk)
    @metal.fetch k, ttl, &blk
  end

  def _cas(k, ttl, &blk)
    @metal.cas k, ttl, &blk
  end

  def _delete(k)
    @metal.delete k
  end

  def _flush
    @metal.flush
  end

  # sux
  def _exist?(k)
    !@metal.get(k).nil?
  end

  def _stats
    @metal.stats
  end
end
