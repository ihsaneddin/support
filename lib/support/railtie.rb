require 'support/importable/concerns/import_methods'
require 'rails'

module Support
  class Railtie < Rails::Railtie
    initializer 'authorization.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Support::Importable::Concerns::ImportMethods
      end
    end
  end
end