require 'helper'

require 'dalli'
require 'active_support/all'
require 'active_support/cache/dalli_store'

class TestActiveSupportCacheDalliStore < Test::Unit::TestCase
  def raw_client_class
    ActiveSupport::Cache::DalliStore
  end

  def raw_client
    raw_client_class.new ['localhost:11211']
  end

  include SharedTests

  def get_ring_object_id
    hidden_dalli_client = @cache.metal.instance_variable_get :@data
    hidden_dalli_client.instance_variable_get(:@ring).object_id
  end

  def test_treats_as_thread_safe
    # make sure ring is initialized
    @cache.get 'hi'

    # get the main thread's ring
    main_thread_ring_id = get_ring_object_id

    # sanity check that it's not changing every time
    @cache.get 'hi'
    assert_equal main_thread_ring_id, get_ring_object_id

    # create a new thread and get its ring
    new_thread_ring_id = Thread.new { @cache.get 'hi'; get_ring_object_id }.value

    # make sure the ring was reinitialized
    assert_equal main_thread_ring_id, new_thread_ring_id
  end

  def test_treats_as_not_fork_safe
    # make sure ring is initialized
    @cache.get 'hi'

    # get the main thread's ring
    parent_process_ring_id = get_ring_object_id

    # sanity check that it's not changing every time
    @cache.get 'hi'
    assert_equal parent_process_ring_id, get_ring_object_id

    # fork a new process
    pid = Kernel.fork do
      @cache.get 'hi'
      raise "Didn't split!" if parent_process_ring_id == get_ring_object_id
    end
    Process.wait pid

    # make sure it didn't raise
    assert $?.success?
  end
end
