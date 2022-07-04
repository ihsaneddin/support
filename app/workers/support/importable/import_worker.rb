begin; require 'sidekiq'; rescue LoadError; end

module Support
  module Importable
    class ImportWorker

      if defined? Sidekiq

        include Sidekiq::Worker
        sidekiq_options :queue => Support.importable.sidekiq_queue, retry: 1, backtrace: Rails.env.development?? 20 : 1

      end
      
      attr_accessor :id
      class_attribute :model

      self.model = Support::Importable::Import

      def perform(id, action, *args)
        self.id = id
        send(action, *args)
      end

      def invoke *args
        resource do |import|
          import.invoke!
        end
      end

      protected

      def resource &block
        if model
          @resource ||= model.find_by_id(self.id)
          if block_given? && @resource
            yield(@resource)
          end
        end
      end

      def model
        self.class.model
      end

    end
  end
end