
require 'helper'

require 'active_support/cache'

class TestActiveSupportCacheNullStore < TestCase
  def raw_client_class
    ActiveSupport::Cache::NullStore
  end

  def test_get
    assert_equal nil, cache.get('hello')
    cache.set 'hello', 'world'
    assert_equal nil, cache.get('hello')
  end

  def test_set
    assert_nothing_raised do
      cache.set 'hello', 'world'
    end
  end

  def test_set_with_ttl
    cache.set 'hello', 'world', 1
    assert_equal nil, cache.get('hello')
    sleep 2
    assert_equal nil, cache.get('hello')
  end

  def test_set_with_zero_ttl_meaning_eternal
    cache.set 'hello', 'world', 0
    assert_equal nil, cache.get('hello')
    sleep 1
    assert_equal nil, cache.get('hello')
  end

  def test_delete
    cache.set 'hello', 'world'
    assert_equal nil, cache.get('hello')
    cache.delete 'hello'
    assert_equal nil, cache.get('hello')
  end

  def test_flush
    cache.set 'hello', 'world'
    assert !cache.exist?('hello')
  end

  def test_exist
    assert !cache.exist?('hello')
    cache.set 'hello', 'world'
    assert !cache.exist?('hello')
  end

  def test_exists
    assert !cache.exists?('hello')
    cache.set 'hello', 'world'
    assert !cache.exists?('hello')
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
    assert_equal nil, cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal nil, cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal nil, cache.get('lights')
    cache.cas 'lights', &toggle
    assert_equal nil, cache.get('lights')
  end

  def test_write
    cache.write 'hello', 'world'
    assert_equal nil, cache.get('hello')
  end

  def test_write_with_expires_in
    cache.write 'hello', 'world', :expires_in => 1
    assert_equal nil, cache.get('hello')
    sleep 2
    assert_equal nil, cache.get('hello')
  end

  def test_write_with_ignored_options
    cache.write 'hello', 'world', :foobar => 'bazboo'
    assert_equal nil, cache.get('hello')
  end

  def test_read
    cache.set 'hello', 'world'
    assert_equal nil, cache.read('hello')
  end

  def test_increment
    assert !cache.exist?('high-fives')
    assert_equal 1, cache.increment('high-fives')
    assert_equal nil, cache.get('high-fives')
    assert_equal 1, cache.increment('high-fives')
    assert_equal nil, cache.get('high-fives')
  end

  def test_decrement
    assert !cache.exist?('high-fives')
    assert_equal -1, cache.decrement('high-fives')
    assert_equal nil, cache.get('high-fives')
    assert_equal -1, cache.decrement('high-fives')
    assert_equal nil, cache.get('high-fives')
  end

  def test_get_multi
    cache.set 'hello', 'world'
    cache.set 'privyet', 'mir'
    assert_equal({}, cache.get_multi('hello', 'privyet', 'yoyoyo'))
  end

  # https://github.com/fauna/memcached/pull/50
  def test_get_set_behavior
    cache.flush
    cache.get 'get_set'
    cache.set 'get_set', 'go'
    assert_equal nil, cache.get('get_set')
  end
end
