# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "google-jwt"
  s.version     = "0.0.1"
  s.authors     = ["Jon Durbin"]
  s.email       = ["jond@greenviewdata.com"]
  s.homepage    = "https://github.com/jondurbin/google-jwt"
  s.summary     = %q{Simple gem for generating google-specific JWT's for OAuth 2.0}
  s.description = %q{Simple gem for generating google-specific JWT's for OAuth 2.0}

  s.rubyforge_project = "google-jwt"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
