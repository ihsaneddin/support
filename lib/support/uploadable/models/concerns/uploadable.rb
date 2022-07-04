require 'ranked-model'

module Support
  module Uploadable
    module Models
      module Concerns
        module Uploadable
          extend ActiveSupport::Concern

          included do

            include Support::Uploadable::Models::Concerns::ActsAsUploadable
            acts_as_uploadable :file, metadata: true, ranked: true, processing_state: true, belongs_to_owner: true

          end

        end
      end
    end
  end
end
