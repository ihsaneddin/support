require_relative "lib/support/version"

Gem::Specification.new do |spec|
  spec.name        = "support"
  spec.version     = Support::VERSION
  spec.authors     = [""]
  spec.email       = ["ihsaneddin@gmail.com"]
  spec.homepage    = "https://github.com/ihsaneddin"
  spec.summary     = "Summary of Support."
  spec.description = "Description of Support."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 7.0.0"

  #uploadable sub module
  spec.add_dependency "shrine", "~> 3.4.0"
  spec.add_dependency "ranked-model", "~> 0.4.8" # ordering of upload records
  spec.add_dependency "marcel", "~> 1.0.2" # mime-type determination
  spec.add_dependency "fastimage", "~> 2.2.3" # mime-type determination
  spec.add_dependency "image_processing", "~> 1.2" # processing wrapper for minimagick/vips
  # spec.add_dependency "shrine-mongoid", "~> 1.0"

  spec.add_dependency "roo", "~> 2.9.0"
  spec.add_dependency 'roo-xls'
  spec.add_dependency 'activerecord-import'
  spec.add_dependency 'aasm'


end
