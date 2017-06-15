require_relative 'lib/gce/host/version'

Gem::Specification.new do |gem|
  gem.name          = "gce-host"
  gem.version       = GCE::Host::VERSION
  gem.author        = ['Naotoshi Seo']
  gem.email         = ['sonots@gmail.com']
  gem.homepage      = 'https://github.com/sonots/gce-host'
  gem.summary       = "Search hosts on GCP GCE"
  gem.description   = "Search hosts on GCP GCE"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.bindir        = "exe"
  gem.executables   = `git ls-files -- exe/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  # v0.12.0 has unintentional incompatibility issues, let us skip it
  # https://github.com/google/google-api-ruby-client/issues/590
  gem.add_runtime_dependency 'google-api-client', '!= 0.12.0'
  gem.add_runtime_dependency 'dotenv'
  gem.add_runtime_dependency 'inifile'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
end
