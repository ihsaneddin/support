module Support
  module Uploadable
    module Grape
      module Helpers
        module Shared

          def uploader
            @uploader||=  Support.uploadable.access.uploader_proc.call(self)
          end

          def uploads_can_be_read? upload = nil
            unless Support.uploadable.access.can_be_read_by(uploader, uploadable, upload, self)
              unauthorized_action!
            end
          end

          def upload_can_be_created? upload = nil
            unless Support.uploadable.access.can_be_created_by(uploader, uploadable, upload, self)
              unauthorized_action!
            end
          end

          def upload_can_be_edited? upload = nil
            unless Support.uploadable.access.can_be_edited_by(uploader, uploadable, upload, self)
              unauthorized_action!
            end
          end

          def upload_can_be_deleted? upload = nil
            unless Support.uploadable.access.can_be_deleted_by(uploader, uploadable, upload, self)
              unauthorized_action!
            end
          end

          def unauthorized_action!
            error!({details: "Unauthorized Action"}, 401)
          end

          def t *args
            I18n.t *args
          end

        end
      end
    end
  end
end