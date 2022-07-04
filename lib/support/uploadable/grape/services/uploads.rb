require_relative "../presenters/upload"

module Support
  module Uploadable
    module Grape
      module Services
        class Uploads < Base

          fetch_resource_and_collection! do
            model_klass "Support::Uploadable::Upload"
            query_scope -> (query) { query.where(uploadable: uploadable) }
            query_includes :uploadable
            got_resource_callback proc { |resource|
              resource.uploadable = uploadable
            }
            attributes do
              optional :name, type: String
              optional :file, type: File
              optional :description, type: String
              optional :order, type: Integer
            end
          end

          set_presenter "Support::Uplodable::Grape::Presenters::Upload"

          resources ":uploadable/:uploadable_id/uploads" do

            desc "Get uploads"
            get "" do
              uploads_can_be_read? @uploads
              presenter(@uploads)
            end

            desc "Create new upload"
            post '' do
              upload_can_be_created? @upload
              if @upload.save
                presenter @upload
              else
                standard_validation_error(details: @upload.errors)
              end
            end

            desc "Update upload"
            put ':id' do
              upload_can_be_edited? @upload
              if @upload.update _resource_params
                presenter @upload
              else
                standard_validation_error(details: @upload.errors)
              end
            end

            desc "Delete upload"
            delete ':id' do
              upload_can_be_deleted? @upload
              if @upload.destroy
                presenter @upload
              end
            end

          end

        end
      end
    end
  end
end