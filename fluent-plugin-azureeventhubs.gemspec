# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-azureeventhubs"
  spec.version       = "0.0.8"
  spec.authors       = ["Hidemasa Togashi", "Toddy Mladenov", "Justin Seely"]
  spec.email         = ["togachiro@gmail.com", "toddysm@gmail.com"]
  spec.summary       = "Fluentd output plugin for Azure Event Hubs"
  spec.description   = "Fluentd output plugin for Azure Event Hubs"
  spec.homepage      = "https://github.com/htgc/fluent-plugin-azureeventhubs"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "fluentd", [">= 0.14.15", "< 2"]
  spec.add_dependency "httpclient", ">= 2.8.3"
end
