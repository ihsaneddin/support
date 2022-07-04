begin; require 'grape'; rescue LoadError; end
begin; require 'grape_api'; rescue LoadError; end
if defined?(Grape::API) && defined?(GrapeAPI::Endpoint::Base)
  require "support/uploadable/grape/services/base"

  Support::Uploadable::Grape::Services::Base.base.namespace :uploadable do
    mount Support::Uploadable::Grape::Services::Uploads
  end

end
