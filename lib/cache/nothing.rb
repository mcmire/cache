
module Cache::Nothing
  def _get(k); end

  def _get_multi(ks); {}; end

  def _set(k, v, ttl); end

  def _fetch(k, ttl)
    yield if block_given?
  end

  def _delete(k); end

  def _flush; end

  def _exist?(k); end

  def _stats; end
end
