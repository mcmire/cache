module Cache::ActiveSupportCacheStore
  def _get(k)
    @metal.read k
  end

  def _get_multi(ks)
    @metal.read_multi *ks
  end

  def _set(k, v, ttl)
    if ttl == 0
      @metal.write k, v # never expire
    else
      @metal.write k, v, :expires_in => ttl
    end
  end

  def _fetch(k, ttl, &blk)
    @metal.fetch k, { :expires_in => _get_ttl(ttl) }, &blk
  end

  def _delete(k)
    @metal.delete k
  end

  def _flush
    @metal.clear
  end

  def _exist?(k)
    @metal.exist? k
    # !get(k).nil?
  end
end
