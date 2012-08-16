require 'helper'

class TestMemoryStoreStorage < Test::Unit::TestCase
  def raw_client_class
    ActiveSupport::Cache::MemoryStore
  end

  def raw_client
    raw_client_class.new
  end

  include SharedTests
end
