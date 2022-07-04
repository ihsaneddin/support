require 'ranked-model'

module Support
  module Uploadable
    module Models
      module Concerns
        class ActsAsUploadableConfig

          attr_accessor :fieldname, :belongs_to_owner, :validations, :processors, :ranked, :metadata, :processing_state

          def initialize **args
            default_args = {
              belongs_to_owner: true,
              field: :file,
              validations: {
                presence: false,
                max_file_size: Support.uploadable.max_file_size,
                whitelist: Support.uploadable.whitelist
              },
              processors:  Support.uploadable.processors,
              ranked: true,
              metadata: true,
              processing_state: true,
            }.merge(args)
            default_args.each do |key,val|
              if respond_to?("#{key}=")
                send("#{key}=", val)
              end
            end
          end

          def merge! **args
            args.each do |key,val|
              if respond_to?("#{key}=")
                send("#{key}=", val)
              end
            end
          end

        end
      end
    end
  end
end
