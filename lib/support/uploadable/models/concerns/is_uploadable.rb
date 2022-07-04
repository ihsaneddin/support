module Support
  module Uploadable
    module Models
      module Concerns
        module IsUploadable

          extend ActiveSupport::Concern

          included do
            @uploadable_processors = nil
            @uploadable_whitelist = nil
            @uploadable_max_file_size = nil

            include HasUpload
            include HasUploads
          end

          class_methods do
            attr_accessor :uploadable_processors, :uploadable_whitelist, :uploadable_max_file_size

            # set custom settings on per-model-basis
            # use after including module like:
            # include Support::Uploadable::Models::Concerns
            # uploadable_set processors: { image: "Processors::CustomImage" },
            #   whitelist: ["image/jpeg"],
            #   max_file_size: 5.megabytes
            def uploadable_set(options = {})
              self.uploadable_processors = options[:processors] unless options[:processors].nil?
              self.uploadable_whitelist = options[:whitelist] unless options[:whitelist].nil?
              self.uploadable_max_file_size = options[:max_file_size] unless options[:max_file_size].nil?
            end

          end

          module HasUpload

            extend ActiveSupport::Concern

            class_methods do

              def has_upload options = { class_name: "Support::Uploadable::Upload" }
                has_one :upload, class_name: options[:class_name], as: :uploadable, dependent: :destroy
                accepts_nested_attributes_for :upload, reject_if: :all_blank, allow_destroy: true
              end

            end

          end

          module HasUploads

            extend ActiveSupport::Concern

            class_methods do

              def has_uploads options = { class_name: "Support::Uploadable::Upload" }
                has_many :uploads, class_name: options[:class_name], as: :uploadable, dependent: :destroy, index_errors: true
                accepts_nested_attributes_for :uploads, reject_if: :all_blank, allow_destroy: true
              end

            end

          end

        end
      end
    end
  end
end