module Cache::ActiveSupportCacheStore
  def _get(k)
    @metal.read k
  end

  def _get_multi(ks)
    @metal.read_multi *ks
  end

  def _set(k, v, ttl)
    if _valid_ttl?(ttl)
      @metal.write k, v, :expires_in => ttl
    else
      @metal.write k, v
    end
  end

  def _fetch(k, ttl, &blk)
    if _valid_ttl?(ttl)
      @metal.fetch k, { :expires_in => ttl }, &blk
    else
      @metal.fetch k, &blk
    end
  end

  def _delete(k)
    @metal.delete k
  end

  def _flush
    @metal.clear
  end

  def _exist?(k)
    @metal.exist? k
  end
end
