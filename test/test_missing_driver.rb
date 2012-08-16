
require 'helper'

class TestMissingDriver < TestCase
  class FooClient; end

  def raw_client_class
    FooClient
  end

  def test_missing_driver
    assert_raises(Cache::DriverNotFound) do
      Cache.new(raw_client)
    end
  end
end
