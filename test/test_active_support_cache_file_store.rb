require 'helper'
require 'tmpdir'
require 'fileutils'

require 'active_support/cache'

class TestActiveSupportCacheFileStore < TestCase
  def raw_client_class
    ActiveSupport::Cache::FileStore
  end

  def raw_client
    tmpdir = File.join(Dir.tmpdir, "Cache-TestActiveSupportCacheFileStore-#{rand(1e11)}")
    FileUtils.mkdir_p tmpdir
    raw_client_class.new tmpdir
  end

  include SharedTests
end
