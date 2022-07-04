module Support
  module Uploadable

    class Upload < Support::ApplicationRecord

      include Support::Uploadable::Models::Concerns::Uploadable

      self.table_name = 'support_uploads'

      def uploadable_type=(class_name)
        super(class_name.constantize.base_class.to_s)
      end

    end

  end
end