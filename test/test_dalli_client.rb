require 'helper'

require 'dalli'

class TestDalliClient < TestCase
  def raw_client_class
    Dalli::Client
  end

  include SharedTests

  def get_ring_object_id
    cache.metal.instance_variable_get(:@ring).object_id
  end

  def test_treats_as_thread_safe
    # make sure ring is initialized
    cache.get 'hi'

    # get the main thread's ring
    main_thread_ring_id = get_ring_object_id

    # sanity check that it's not changing every time
    cache.get 'hi'
    assert_equal main_thread_ring_id, get_ring_object_id

    # create a new thread and get its ring
    new_thread_ring_id = Thread.new { cache.get 'hi'; get_ring_object_id }.value

    # make sure the ring was reinitialized
    assert_equal main_thread_ring_id, new_thread_ring_id
  end

  def test_treats_as_not_fork_safe
    # make sure ring is initialized
    cache.get 'hi'

    # get the main thread's ring
    parent_process_ring_id = get_ring_object_id

    # sanity check that it's not changing every time
    cache.get 'hi'
    assert_equal parent_process_ring_id, get_ring_object_id

    # fork a new process
    pid = Kernel.fork do
      cache.get 'hi'
      raise "Didn't split!" if parent_process_ring_id == get_ring_object_id
    end
    Process.wait pid

    # make sure it didn't raise
    assert $?.success?
  end

  def test_set_with_default_dalli_ttl
    cache = Cache.new(Dalli::Client.new(nil, :expires_in => 1))
    cache.set('foo', 'bar')
    sleep 2
    assert_equal nil, cache.get('foo')
  end

  def test_fetch_with_default_dalli_ttl
    cache = Cache.new(Dalli::Client.new(nil, :expires_in => 1))
    cache.fetch('foo') { 'bar' }
    sleep 2
    assert_equal nil, cache.fetch('foo')
    assert_equal 'different', cache.fetch('foo') { 'different' }
  end
end
