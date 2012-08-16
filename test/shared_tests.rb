module SharedTests
  def test_metal
    assert_equal raw_client_class, cache.metal.class
  end

  def test_wrap_twice
    c = Cache.new(Cache.new(raw_client))
    assert_equal raw_client_class, c.metal.class
  end

  def test_wrap_absurd
    c = Cache.new(Cache.new(Cache.new(raw_client)))
    assert_equal raw_client_class, c.metal.class
  end

  def test_get
    assert_equal nil, cache.get('hello')
    cache.set 'hello', 'world'
    assert_equal 'world', cache.get('hello')
  end

  def test_set
    assert_nothing_raised do
      cache.set 'hello', 'world'
    end
  end

  def test_set_with_ttl
    cache.set 'hello', 'world', 1
    assert_equal 'world', cache.get('hello')
    sleep 2
    assert_equal nil, cache.get('hello')
  end

  def test_set_with_zero_ttl_meaning_eternal
    cache.set 'hello', 'world', 0
    assert_equal 'world', cache.get('hello')
    sleep 1
    assert_equal 'world', cache.get('hello')
  end

  def test_delete
    cache.set 'hello', 'world'
    assert_equal 'world', cache.get('hello')
    cache.delete 'hello'
    assert_equal nil, cache.get('hello')
  end

  def test_flush
    cache.set 'hello', 'world'
    assert cache.exist?('hello')
    cache.flush
    assert !cache.exist?('hello')
  end

  def test_exist
    assert !cache.exist?('hello')
    cache.set 'hello', 'world'
    assert cache.exist?('hello')
  end

  def test_exists
    assert !cache.exists?('hello')
    cache.set 'hello', 'world'
    assert cache.exists?('hello')
  end

  # This is not working with the Dalli client
  #def test_exist_key_with_nil_value
  #  assert !cache.exist?('hello')
  #  cache.set 'hello', nil
  #  assert cache.exist?('hello')
  #end

  def test_stats
    assert_nothing_raised do
      cache.stats
    end
  end

  def test_fetch
    assert_equal nil, cache.fetch('hello')
    assert_equal 'world', cache.fetch('hello') { 'world' }
  end

  def test_fetch_with_false_boolean
    assert_equal nil, cache.fetch('hello')
    assert_equal false, cache.fetch('hello') { false }
  end

  def test_fetch_with_expires_in
    assert_equal 'world', cache.fetch('hello', :expires_in => 5) { 'world' }
  end

  def test_fetch_with_expires_in_stringified
    assert_equal 'world', cache.fetch('hello', 'expires_in' => 5) { 'world' }
  end

  def test_fetch_with_ignored_options
    assert_equal 'world', cache.fetch('hello', :foo => 'bar') { 'world' }
  end

  def test_cas
    toggle = lambda do |current|
      current == 'on' ? 'off' : 'on'
    end

    cache.set 'lights', 'on'
    assert_equal 'on', cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal 'off', cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal 'on', cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal 'off', cache.get('lights')
  end

  def test_write
    cache.write 'hello', 'world'
    assert_equal 'world', cache.get('hello')
  end

  def test_write_with_expires_in
    cache.write 'hello', 'world', :expires_in => 1
    assert_equal 'world', cache.get('hello')
    sleep 2
    assert_equal nil, cache.get('hello')
  end

  def test_write_with_ignored_options
    cache.write 'hello', 'world', :foobar => 'bazboo'
    assert_equal 'world', cache.get('hello')
  end

  def test_read
    cache.set 'hello', 'world'
    assert_equal 'world', cache.read('hello')
  end

  def test_increment
    assert !cache.exist?('high-fives')
    assert_equal 1, cache.increment('high-fives')
    assert_equal 1, cache.get('high-fives')
    assert_equal 2, cache.increment('high-fives')
    assert_equal 2, cache.get('high-fives')
  end

  def test_decrement
    assert !cache.exist?('high-fives')
    assert_equal -1, cache.decrement('high-fives')
    assert_equal -1, cache.get('high-fives')
    assert_equal -2, cache.decrement('high-fives')
    assert_equal -2, cache.get('high-fives')
  end

  def test_get_multi
    cache.set 'hello', 'world'
    cache.set 'privyet', 'mir'
    assert_equal({ 'hello' => 'world', 'privyet' => 'mir'}, cache.get_multi('hello', 'privyet', 'yoyoyo'))
  end

  # https://github.com/fauna/memcached/pull/50
  def test_get_set_behavior
    cache.flush
    cache.get 'get_set'
    cache.set 'get_set', 'go'
    assert_equal 'go', cache.get('get_set')
  end
end
