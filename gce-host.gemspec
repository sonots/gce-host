Gem::Specification.new do |gem|
  gem.name          = "gce-host"
  gem.version       = '0.1.0'
  gem.author        = ['Naotoshi Seo']
  gem.email         = ['sonots@gmail.com']
  gem.homepage      = 'https://github.com/sonots/gce-host'
  gem.summary       = "Search hosts on GCP GCE"
  gem.description   = "Search hosts on GCP GCE"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'google-api-client'
  gem.add_runtime_dependency 'dotenv'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
end
