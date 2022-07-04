require_relative "../helpers/shared"

module Support
  module Uploadable
    module Grape
      module Services
        class Base < ::GrapeAPI::Endpoint::Base

          format :json

          helpers Support::Uploadable::Grape::Helpers::Shared

          helpers do

            def uploadable
              @uploadable ||= uploadable_class.find(params[:uploadable_id])
            end

            def uploadable_class
              params[:uploadable].to_s.classify.constantize rescue error!({details: "Uploadable class Not Found!"}, 404)
            end

          end

        end
      end
    end
  end
end

require_relative "./uploads"