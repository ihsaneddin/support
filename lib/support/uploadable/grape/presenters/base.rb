require 'grape-entity'

module Support
  module Uploadable
    module Grape
      module Presenters

        class Base < ::Grape::Entity
          root "data", "data"
        end

      end
    end
  end
end