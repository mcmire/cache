require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache'

if ::Bundler.definition.specs['ruby-debug19'].first or ::Bundler.definition.specs['ruby-debug'].first
  require 'ruby-debug'
end

require 'shared_tests'

class TestCase < Test::Unit::TestCase
  def raw_client_class
    raise NotImplementedError, "You must add a #raw_client_class method to your test case"
  end

  def raw_client
    raw_client_class.new
  end

  def cache
    @cache ||= Cache.new(raw_client).tap {|c| c.flush }
  end
end

ENV['CACHE_DEBUG'] = 'true'
