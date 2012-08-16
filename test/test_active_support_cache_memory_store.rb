require 'helper'

require 'active_support/cache'

class TestActiveSupportCacheMemoryStore < TestCase
  def raw_client_class
    ActiveSupport::Cache::MemoryStore
  end

  include SharedTests
end

