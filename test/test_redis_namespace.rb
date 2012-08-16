require 'helper'

require 'redis'
require 'redis-namespace'

class TestRedisNamespaceStorage < TestCase
  def raw_client_class
    Redis::Namespace
  end

  def raw_client
    raw_client_class.new(:test_cache, :redis => Redis.new)
  end

  include SharedTests

  # client DOT client
  def get_redis_client_connection_socket_id
    connection = cache.metal.client.instance_variable_get :@connection
    sock = connection.instance_variable_get(:@sock)
    # $stderr.puts sock.inspect
    sock.object_id
  end

  def test_treats_as_thread_safe
    # make sure ring is initialized
    cache.get 'hi'

    # get the main thread's ring
    main_thread_redis_client_connection_socket_id = get_redis_client_connection_socket_id

    # sanity check that it's not changing every time
    cache.get 'hi'
    assert_equal main_thread_redis_client_connection_socket_id, get_redis_client_connection_socket_id

    # create a new thread and get its ring
    new_thread_redis_client_connection_socket_id = Thread.new { cache.get 'hi'; get_redis_client_connection_socket_id }.value

    # make sure the ring was reinitialized
    assert_equal main_thread_redis_client_connection_socket_id, new_thread_redis_client_connection_socket_id
  end

  def test_treats_as_not_fork_safe
    # make sure ring is initialized
    cache.get 'hi'

    # get the main thread's ring
    parent_process_redis_client_connection_socket_id = get_redis_client_connection_socket_id

    # sanity check that it's not changing every time
    cache.get 'hi'
    assert_equal parent_process_redis_client_connection_socket_id, get_redis_client_connection_socket_id

    # fork a new process
    pid = Kernel.fork do
      cache.get 'hi'
      raise "Didn't split!" if parent_process_redis_client_connection_socket_id == get_redis_client_connection_socket_id
    end
    Process.wait pid

    # make sure it didn't raise
    assert $?.success?
  end
end
