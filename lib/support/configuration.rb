require 'shrine'
require 'shrine/storage/file_system'

module Support
  module Configuration

    module Uploadable

      mattr_accessor :shrine
      @@shrine = Shrine

      def self.shrine_setup &block
        yield(@@shrine)
      end

       # upload directory (string)
      mattr_accessor :uploads_dir
      @@uploads_dir = "public"

      # prefix for uploads folder within config.uploads_dir (string)
      mattr_accessor :uploads_prefix
      @@uploads_prefix = "uploads"

      # sub class of Shrine
      mattr_accessor :file_uploader_cname
      @@file_uploader_cname = 'Support::Uploadable::FileUploader::Attachment'

      def self.file_uploader_class
        @@file_uploader_cname.constantize
      end

      # to determine file is required or not
      mattr_accessor :file_is_required
      @@file_is_required = false

      # execute file processing in background (boolean)
      # this requires a runnning sidekiq instance
      mattr_accessor :process_in_background
      @@process_in_background = false

      #name of sidekiq queue if process_in_background is enabled
      mattr_accessor :sidekiq_queue
      @@sidekiq_queue = :default

      # processing on a per-type basis (false / hash)
      # processors = false
      # disables processing
      # processors = { image: Processors::Image, video: Processors::Video }
      # uses custom processors per file type
      #
      # a processor needs a self.process(file) method
      # see support/app/uploaders/uploadable/processors/*.rb for example processors
      mattr_accessor :processors
      @@processors = false

      # whitelist for allowed mime-types (array)
      # %W(image/jpg image/gif image/png video/mp4)
      # false allows all file types
      mattr_accessor :whitelist
      @@whitelist = false

      # maximum filesize limit in bytes (integer)
      # false disables limitation
      # can be set to Rails filesize objects
      # 1.megabyte, 2.kilobytes, etc.
      mattr_accessor :max_file_size
      @@max_file_size = false

      def self.setup &block
        yield self
      end

      module Access

        mattr_accessor :uploader_proc
        @@uploader_proc = -> (context) { context.current_user }

        mattr_accessor :can_be_read_by_proc
        @@can_be_read_by_proc = -> (uploader_proc) { true }

        mattr_accessor :can_be_created_by_proc
        @@can_be_created_by_proc = -> (uploader_proc) { true }

        mattr_accessor :can_be_edited_by_proc
        @@can_be_edited_by_proc = -> (uploader_proc) { true }

        mattr_accessor :can_be_deleted_by_proc
        @@can_be_deleted_by_proc = -> (uploader_proc) { true }

        class << self
          def setup &block
            yield self
          end

          def uploader context = nil
            if block_given?
              @@uploader_proc = Proc.new
            else
              @@uploader_proc.call(context)
            end
          end

          def can_be_read_by uploader = nil, upload = nil, uploadable = nil,  context= nil
            if block_given?
              @@can_be_read_by_proc = Proc.new
            else
              @@can_be_read_by_proc.call(uploader, uploadable, upload, context)
            end
          end

          def can_be_created_by uploader = nil, upload = nil, uploadable = nil, context= nil
            if block_given?
              @@can_be_created_by_proc = Proc.new
            else
              @@can_be_created_by_proc.call(uploader, uploadable, upload, context)
            end
          end

          def can_be_edited_by uploader = nil, upload = nil, uploadable = nil, context= nil
            if block_given?
              @@can_be_edited_by_proc = Proc.new
            else
              @@can_be_edited_by_proc.call(uploader, uploadable, upload, context)
            end
          end

          def can_be_deleted_by uploader = nil, upload = nil, uploadable = nil, context= nil
            if block_given?
              @@can_be_deleted_by_proc = Proc.new
            else
              @@can_be_deleted_by_proc.call(uploader, uploadable, upload = nil, context)
            end
          end
        end

      end
       mattr_accessor :access
       @@access = Access

    end

    module Importable

      #name of sidekiq queue if process_in_background is enabled
      mattr_accessor :sidekiq_queue
      @@sidekiq_queue = :default

      def self.setup &block
        yield self
      end

    end

    mattr_accessor :uploadable
    @@uploadable = Uploadable

    mattr_accessor :importable
    @@importable = Importable

  end
end