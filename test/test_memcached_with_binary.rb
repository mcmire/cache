require 'helper'

unless RUBY_PLATFORM == 'java'
  require 'memcached'

  class TestMemcachedWithBinary < TestCase
    def raw_client_class
      Memcached
    end

    def raw_client
      raw_client_class.new 'localhost:11211', :support_cas => true, :binary => true
    end

    include SharedTests
  end
end
