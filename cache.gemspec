# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cache/version"

Gem::Specification.new do |s|
  s.name        = "cache"
  s.version     = Cache::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere","Christoph Grabo"]
  s.email       = ["seamus@abshere.net","chris@dinarrr.com"]
  s.homepage    = "https://github.com/seamusabshere/cache"
  s.summary     = %q{A unified cache handling interface inspired by libraries like ActiveSupport::Cache::Store, Perl's Cache::Cache, CHI, etc.}
  s.description = %q{Wraps memcached, redis(-namespace), memcache-client, dalli and handles their weirdnesses, including forking}

  s.rubyforge_project = "cache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

