lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails_autoscale/sidekiq/version"

Gem::Specification.new do |spec|
  spec.name = "rails-autoscale-sidekiq"
  spec.version = RailsAutoscale::Sidekiq::VERSION
  spec.authors = ["Adam McCrea", "Carlos Antonio da Silva"]
  spec.email = ["adam@adamlogic.com"]

  spec.summary = "This gem provides Sidekiq integration with the Judoscale autoscaling add-on for Heroku."
  spec.homepage = "https://judoscale.com"
  spec.license = "MIT"

  spec.metadata = {
    "homepage_uri" => "https://judoscale.com",
    "bug_tracker_uri" => "https://github.com/judoscale/judoscale-ruby/issues",
    "documentation_uri" => "https://judoscale.com/docs",
    "changelog_uri" => "https://github.com/judoscale/judoscale-ruby/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/judoscale/judoscale-ruby"
  }

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_dependency "rails-autoscale-core"
  spec.add_dependency "sidekiq", ">= 5.0"
end
