require 'support/configuration'
require 'ranked-model'
require 'aasm'
require 'roo'
require 'roo-xls'
require 'support/uploadable/models/concerns/uploadable'
require 'support/uploadable/models/concerns/acts_as_uploadable'
require 'support/uploadable/models/concerns/is_uploadable'
require 'support/optionable/models/concerns/optionable'
require 'support/railtie' if defined?(Rails)

require "support/version"
require "support/engine"
require 'shrine'

module Support
  extend Support::Configuration
end

require 'support/hooks'