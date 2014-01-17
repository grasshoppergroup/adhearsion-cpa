# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adhearsion_cpa/version"

Gem::Specification.new do |s|
  s.name        = "adhearsion_cpa"
  s.version     = AdhearsionCpa::VERSION
  s.authors     = ["Justin Aiken"]
  s.email       = ["60tonangel@gmail.com"]
  s.license     = 'MIT'
  s.homepage    = "https://github.com/grasshoppergroup/adhearsion-cpa"
  s.summary     = %q{A plugin for adding cpa to Adhearsion}
  s.description = %q{A plugin for adding cpa to Adhearsion}

  s.rubyforge_project = "adhearsion_cpa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.4"]
  s.add_runtime_dependency %q<punchblock>, ["> 2.2.1"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]

  s.add_development_dependency %q<coveralls>, ['>= 0']
  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.5"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
 end
