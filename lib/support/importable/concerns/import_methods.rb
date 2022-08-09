module Support
  module Importable
    module Concerns
      module ImportMethods
        extend ActiveSupport::Concern
    
        module ClassMethods
    
          def new_import
            Import::Models::Import.new context: self.name
          end
    
          def importable options = {}
            extend Helpers
            headers = try(:column_names) rescue []
            default = { after_import: nil, headers: headers, header_row: 1, :process_row => nil, :validation => false, :batch => false, :label => nil, reject_blank: true }
            options = default.merge options
            class_attribute :importable_options
            self.importable_options = options
            if block_given?
              yield
            end
          end
    
        end
    
        module Helpers
    
          def import_process_row &block
            if block_given?
              self.importable_options[:process_row] = block
            end
          end
    
          def after_import &block
            if block_given?
              self.importable_options[:after_import] = block
            end
          end
    
          def import_headers *headers
            if headers.present?
              self.importable_options[:headers] = headers
            end
            if block_given?
              self.importable_options[:headers] = yield
            end
          end
    
          def import_header_row row = nil
            if row.present?
              self.importable_options[:header_row] = row
            end
            if block_given?
              self.importable_options[:header_row] = yield
            end
          end
    
          def import_validation validation = nil
            if validation.present?
              self.importable_options[:validation] = validation
            end
            if block_given?
              self.importable_options[:validation] = yield
            end
          end
    
          def import_transaction tran = nil
            if tran.present?
              self.importable_options[:transaction] = tran
            end
            if block_given?
              self.importable_options[:transaction] = yield
            end
          end
    
          def import_batch batch = nil
            if batch.present?
              self.importable_options[:batch] = batch
            end
            if block_given?
              self.importable_options[:transaction] = yield
            end
          end
    
          def importable_option_of key, *params
            opt = self.importable_options.dig key
            case opt
            when Proc
              opt.call(*params)
            else
              opt
            end
          end
    
        end
      end
    end
  end
end