# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "king_konf/version"

Gem::Specification.new do |spec|
  spec.name = "king_konf"
  spec.version = KingKonf::VERSION
  spec.authors = ["Daniel Schierbeck"]
  spec.email = ["daniel.schierbeck@gmail.com"]

  spec.summary = "A simple configuration library"
  spec.description = "A simple configuration library"
  spec.homepage = "https://github.com/dasch/king_konf"
  spec.license = "Apache License Version 2.0"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
end
