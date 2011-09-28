# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tweetbot/version"

Gem::Specification.new do |s|
  s.name        = "tweetbot"
  s.version     = Tweetbot::VERSION
  s.authors     = ["coreyhaines"]
  s.email       = ["coreyhaines@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Tweetbot makes writing twitter bots twivial!}
  s.description = %q{Using tweetbot, you can easily create twitter bots that respond to key phrases that people say on the twitters}

  s.rubyforge_project = "tweetbot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "twitter"
  s.add_runtime_dependency "tweetstream", "1.1.0.rc2"
end
