$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lazy_developer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lazy_developer"
  s.version     = LazyDeveloper::VERSION
  s.authors     = ["Brian Hogan"]
  s.email       = ["brianhogan@napcs.com"]
  s.homepage    = "http://github.com/napcs/lazy_developer"
  s.summary     = "Collection of tasks to ease the life of the lazy developer"
  s.description = "Collection of tasks to ease the life of the lazy developer."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0.0"

  s.add_development_dependency "sqlite3"
end
