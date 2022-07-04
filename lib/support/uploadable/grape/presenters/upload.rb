require_relative "./base"

module Support
  module Uploadable
    module Grape
      module Presenters

        class Upload < Base
          expose :id
          expose :name
          expose :file_url do |res|
            if Support.uploadable.shrine.storages.dig(:store).is_a?(Shrine::Storage::FileSystem)
              "#{ENV['BASE_URL'] || 'http://localhost:3000'}#{res.file_url}"
            else
              res.file_url
            end
          end
          expose :metadata
          expose :file_data do |res|
            JSON.parse(res.file_data) rescue {}
          end
          expose :uploadable_id
          expose :uploadable_type
          expose :order
          expose :description
          expose :created_at
          expose :updated_at
        end

      end
    end
  end
end