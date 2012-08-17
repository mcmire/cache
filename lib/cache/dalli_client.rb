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
    if _valid_ttl?(ttl)
      @metal.set k, v, ttl
    else
      @metal.set k, v
    end
  end

  def _fetch(k, ttl, &blk)
    if _valid_ttl?(ttl)
      @metal.fetch k, ttl, &blk
    else
      @metal.fetch k, &blk
    end
  end

  def _cas(k, ttl, &blk)
    if _valid_ttl?(ttl)
      @metal.cas k, ttl, &blk
    else
      @metal.cas k, &blk
    end
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
