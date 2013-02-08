require 'helper'

require 'active_support/cache'
require 'memcache'

class TestActiveSupportCacheMemoryStore < TestCase
  def raw_client_class
    ActiveSupport::Cache::MemCacheStore
  end

  include SharedTests
end

