require 'ranked-model'
require_relative './acts_as_uploadable_config'

module Support
  module Uploadable
    module Models
      module Concerns
        module ActsAsUploadable
          extend ActiveSupport::Concern

          class_methods do

            def acts_as_uploadable *args
              include ActsAsUploadableClassMethods
              include ActsAsUploadableInstanceMethods
              options  = args.extract_options!
              fields = args.flatten

              fields.each do |field|
                unless options.blank?
                  uploadable_config_merge! fieldname: field, config: options
                end
                _validations = uploadable_validations fieldname: field
                if (_validations.is_a?(Hash))
                  if _validations[:presence]
                    validates field, presence: true
                  end
                end
                include Support.uploadable.file_uploader_class.new(field)

                _ownership = uploadable_belongs_to_owner(fieldname: field)
                if _ownership
                  if _ownership.is_a?(Array)
                    belongs_to _ownership
                  else
                    belongs_to :uploadable, polymorphic: true, optional: true
                  end
                end

                _meta = uploadable_metadata(fieldname: field)

                if _meta
                  before_validation do
                    self.metadata= {} if respond_to?(:metadata) and metadata.nil?
                  end
                  after_initialize do
                    self.metadata= {} if respond_to?(:metadata) and metadata.nil?
                  end
                  if column_names.include?(:metadata)
                    serialize :metadata, Hash
                  end
                end

                _ranked = uploadable_ranked(fieldname: field)

                if _ranked
                  include RankedModel
                  if _ranked.is_a?(Array)
                    ranks *_ranked
                    scope :ordered, -> { rank(_ranked[0]) }
                  else
                    ranks :order, with_same: [:uploadable_id, :uploadable_type]
                    scope :ordered, -> { rank(:order) }
                  end
                end

              end

            end

          end

          module ActsAsUploadableClassMethods
            extend ActiveSupport::Concern
            included do
              class_attribute :_uploadable_config
              self._uploadable_config = {}
            end

            class_methods do

              def uploadable_config_merge! fieldname:, config: {}
                current_config = uploadable_config fieldname: fieldname
                current_config.merge!(config)
                self._uploadable_config[self.name][fieldname] = current_config
              end

              def uploadable_config fieldname:, key: nil
                if self._uploadable_config[self.name].nil?
                  self._uploadable_config[self.name] = {}
                end
                if self._uploadable_config[self.name][fieldname.to_sym].nil?
                  self._uploadable_config[self.name][fieldname.to_sym] = ActsAsUploadableConfig.new
                end
                if(key)
                  return self._uploadable_config[self.name][fieldname.to_sym].send(key)
                else
                  return self._uploadable_config[self.name][fieldname.to_sym]
                end
              end

              def uploadable_belongs_to_owner fieldname: nil, options: nil
                if options
                  uploadable_config(fieldname: fieldname).belongs_to_owner= options
                end
                uploadable_config(fieldname: fieldname).belongs_to_owner
              end

              def uploadable_processors fieldname: , processors: nil
                if processors
                  uploadable_config(fieldname: fieldname).processors = processors
                end
                uploadable_config(fieldname: fieldname).processors
              end

              def uploadable_validations fieldname:, validations: nil
                if validations
                  uploadable_config(fieldname: fieldname).validations= validations
                end
                uploadable_config(fieldname: fieldname).validations
              end

              def uploadable_ranked fieldname:, ranked: nil
                if ranked
                  uploadable_config(fieldname: fieldname).ranked= ranked
                end
                uploadable_config(fieldname: fieldname).ranked
              end

              def uploadable_processing_state fieldname:, processing_state: nil
                if processing_state
                  uploadable_config(fieldname: fieldname).processing_state= processing_state
                end
                uploadable_config(fieldname: fieldname).processing_state
              end

              def uploadable_metadata fieldname:, metadata: nil
                if metadata
                  uploadable_config(fieldname: fieldname).metadata= metadata
                end
                uploadable_config(fieldname: fieldname).metadata
              end

            end
          end

          module ActsAsUploadableInstanceMethods
            extend ActiveSupport::Concern

            def processors fieldname
              _processors = self.class.uploadable_processors fieldname: fieldname
              _processors
            end

            def whitelist fieldname
              _validations = self.class.uploadable_validations(fieldname: fieldname)
              _validations.is_a?(Hash) ? _validations[:whitelist] : false
            end

            def max_file_size fieldname
              _validations = self.class.uploadable_validations(fieldname: fieldname)
              _validations.is_a?(Hash) ? _validations[:max_file_size] : false
            end

            def mime_type
              self.metadata['mime_type']
            end

            def filetype
              self.mime_type.split('/')[0] if self.mime_type
            end

            def has_versions?
              self.file.is_a?(Hash) ? true : false
            end

            def reluctant_file(version = nil)
              if self.has_versions? && version.blank?
                self.file[self.file.keys.first]
              elsif self.has_versions? && !version.blank?
                self.file[version].blank? ? self.file[self.file.keys.first] : self.file[version]
              else
                self.file
              end
            end

            def image?
              self.filetype == "image" ? true : false
            end

            def video?
              self.filetype == "video" ? true : false
            end

            private

              def set_processing_state
                if file_data_changed? && file_attacher.cached?
                  self.processing = true
                elsif file_data_changed? && file_attacher.stored?
                  self.processing = false
                end
              end

              def set_mime_type
                self.metadata = {} if self.metadata.nil?
                self.metadata['mime_type'] = self.reluctant_file.mime_type
              end

          end

        end
      end
    end
  end
end
