Support.uploadable.setup do |config|

   # upload directory (string)
   #config.uploads_dir = "public"

   # prefix for uploads folder within config.uploads_dir (string)
   #config.uploads_prefix = "uploads"

   # sub class of Shrine
   #config.file_uploader_cname = 'Support::Uploadable::FileUploader::Attachment'

   # to determine file is required or not
   #config.file_is_required = false

   # execute file processing in background (boolean)
   # this requires a runnning sidekiq instance
   #config.process_in_background = false
   #config.sidekiq_queue = :default

   # processing on a per-type basis (false / hash)
   # processors = false
   # disables processing
   # processors = { image: Processors::Image, video: Processors::Video }
   # uses custom processors per file type
   #
   # a processor needs a self.process(file) method
   # see support/app/uploaders/uploadable/processors/*.rb for example processors
   config.processors = false

   # whitelist for allowed mime-types (array)
   # %W(image/jpg image/gif image/png video/mp4)
   # false allows all file types
   config.whitelist = false

   # maximum filesize limit in bytes (integer)
   # false disables limitation
   # can be set to Rails filesize objects
   # 1.megabyte, 2.kilobytes, etc.
   config.max_file_size = false

  config.shrine_setup do |shrine|
    shrine.storages = {
      cache: shrine::Storage::FileSystem.new(Support.uploadable.uploads_dir, prefix: File.join(Support.uploadable.uploads_prefix, "/cache")),
      store: shrine::Storage::FileSystem.new(Support.uploadable.uploads_dir, prefix: Support.uploadable.uploads_prefix)
    }

    shrine.plugin :activerecord # use ActiveRecord
    shrine.plugin :cached_attachment_data # cache attachment data across request
    shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file
    shrine.plugin :determine_mime_type, analyzer: :marcel # determine mime-type
    # shrine.plugin :infer_extension, force: true # deduce extension from actual mime-type (with 'mime-types' gem)
    shrine.plugin :store_dimensions # store dimensions in file metadata
    shrine.plugin :delete_raw unless (Rails.env.development? || Rails.env.test?) # delete raw file after upload
    shrine.plugin :remove_invalid # delete invalid files
    shrine.plugin :versions # create versions
    shrine.plugin :processing # process uploaded files
    shrine.plugin :validation_helpers # validation
    shrine.plugin :backgrounding # process in background job
    shrine.plugin :upload_endpoint # endpoint for XHR uploads
    # shrine.plugin :hooks # callbacks
  end

  #access configuration for endpoints and controllers of uploads
  # config.access.setup do |access|
  #   access.current_user do |context|
  #     context.current_user
  #   end

  #   access.can_be_read_by do |current_user, uploadable, upload, context|
  #     true
  #   end

  #   access.can_be_created_by do |current_user, uploadable, upload, context|
  #     true
  #   end

  #   access.can_be_edited_by do |current_user, uploadable, upload, context|
  #     true
  #   end

  #   access.can_be_deleted_by do |current_user, uploadable, upload, context|
  #     true
  #   end
  # end

end