module Support
  module Importable
    class Import < ApplicationRecord

      self.table_name = 'support_imports'

      include AASM

      validates :context, presence: true
      validate :context_is_valid

      def context_is_valid
        unless context_class.present? && context_class.ancestors.include?(::ActiveRecord::Base)
          errors.add(:context, "Invalid context")
        end
      end

      aasm column: :state, use_transactions: false do

        state :pending, initial: true
        state :delayed_invoke
        state :imported

        event :invoke do
          transitions from: [:pending, :delayed_invoke], to: :imported do
            guard do
              eligible_for_import?
              invoke_import!
            end
          end
        end

        event :delayed_invoke do
          transitions from: [:pending, :delayed_invoke], to: :delayed_invoke do
            after do
              delayed_import!
            end
          end
        end

      end

      include Support::Optionable::Models::Concerns::Optionable

      has_options(
        fields: {
          imported_ids: [],
          information: {},
          configuration: {
            headers: nil, header_row: nil, validation: nil, transaction: nil, batch: nil, force_save: nil, label: nil, reject_blank: true
          }
        }
      )

      include Support::Uploadable::Models::Concerns::IsUploadable

      has_upload
      uploadable_set white_list: ['application/xls', 'application/xlsx', 'application/csv']

      def invoke_import!
        open_spreadsheet do |spreadsheet|
          header_row = configuration_of :header_row
          header_names = configuration_of :headers
          header_names = header_names.symbolize_keys
          batch = configuration_of :batch
          attrs = []
          headers = spreadsheet.row(header_row)
          ((header_row + 1)..spreadsheet.last_row).map do |i|
            row = Hash[[headers, spreadsheet.row(i)].transpose]
            row = row.delete_if {|key, val| key.nil? }
            case header_names
            when Hash
              row = row.transform_keys{|key| header_names[key.to_sym].nil?? key : header_names[key.to_sym] }.delete_if{|key, val| !header_names.values.include?(key) }
            when Array
              row = row.delete_if{|key, val| !header_names.include?(key) }
            end
            if batch
              process_row = configuration_of :process_row, row
              if process_row.is_a? Proc
                row = process_row.call(row)
              end
            end
            attrs << row
          end
          validation = configuration_of :validation
          transaction = configuration_of :transaction
          res = []
          if batch
            if transaction
              res = import_batch_attributes! attrs, validation
            else
              res = import_batch_attributes attrs, validation
            end
          else
            if transaction
              res = import_attributes! attrs, validation
            else
              res = import_attributes attrs, validation
            end
          end
          self.option_imported_ids = res.map(&:id)
        end
        return self.save
      end

      def delayed_import!
        if defined? Sidekiq
          Support::Importable::ImportWorker.perform_at(15.seconds.from_now, self.id, "invoke")
        end
      end

      def import_attributes attrs = [], validation=false
        header_row = configuration_of :header_row
        res = []
        attrs.each_with_index do |attr, index|
          parsed_attr = attr.dup
          process_attr = configuration_of :process_row, parsed_attr
          if process_attr.is_a? Proc
            parsed_attr = process_row.call(parsed_attr)
          end
          begin
            record = context_class.new(parsed_attr)
            record.save validate: validation
            if record.errors.any?
              row_number = index + header_row + 1
              unless self.option_information[:errors].is_a? Array
                self.option_information[:errors] = []
              end
              self.option_information[:errors] << { attributes: parsed_attr, message: record.errors.messages, row_number: row_number }
            else
              configuration_of :after_import, record, parsed_attr, attr
              res << record
            end
          rescue => e
            row_number = index + header_row + 1
            unless self.option_information[:errors].is_a? Array
              self.option_information[:errors] = []
            end
            self.option_information[:errors] << { attributes: attr, message: e.message }
          end
        end
        res
      end

      def import_attributes! attrs = [], validation=false
        begin
          ActiveRecord::Base.transaction do
            return import_attributes attrs, validation
          end
        rescue => e
          self.option_information[:errors] = e.message
        end
      end

      def import_batch_attributes attrs = [], validation=false
        context_class.import attrs, validate: validation
      end

      def import_batch_attributes! attrs = [], validation= false
        begin
          ActiveRecord::Base.transaction do
            return import_batch_attributes attrs, validation
          end
        rescue => e
          self.option_information[:errors] = e.message
        end
      end

      def eligible_for_import?
        upload && upload.file.present? and context_class.present?
      end

      def open_spreadsheet
        if upload
          document = upload
          case document.file.try(:extension)
          when "xlsx"
            spreadsheet = Roo::Spreadsheet.open(document.file.url, extension: document.file.extension)
          when "xls"
            spreadsheet = Roo::Spreadsheet.open(document.file.url, extension: document.file.extension)
          when "csv"
            spreadsheet = Roo::CSV.new(document.file.url, extension: :csv)
          else
            raise "Unknown file type: #{document.file.try :filename}"
          end
          if block_given?
            yield(spreadsheet)
          else
            spreadsheet
          end
        else
          raise "Missing file"
        end
      end

      def context_class
        context.constantize rescue nil
      end

      def configuration_of key, *params
        opt = self.option_configuration.dig key
        if opt.nil?
          opt = context_class.importable_option_of key, *params
        end
        opt
      end

      class << self

        def initialize_for_context context
          self.new context: context.to_s
        end

      end

    end
  end
end