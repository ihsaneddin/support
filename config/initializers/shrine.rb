require 'shrine'
require 'shrine/storage/file_system'

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new(Support.uploadable.uploads_dir, prefix: File.join(Support.uploadable.uploads_prefix, "/cache")),
  store: Shrine::Storage::FileSystem.new(Support.uploadable.uploads_dir, prefix: Support.uploadable.uploads_prefix)
}

#Shrine.storages[:cache] = Shrine.storages[:tus]

Shrine.plugin :activerecord # use ActiveRecord
Shrine.plugin :cached_attachment_data # cache attachment data across request
Shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file
Shrine.plugin :determine_mime_type, analyzer: :marcel # determine mime-type
# Shrine.plugin :infer_extension, force: true # deduce extension from actual mime-type (with 'mime-types' gem)
Shrine.plugin :store_dimensions # store dimensions in file metadata
Shrine.plugin :delete_raw unless (Rails.env.development? || Rails.env.test?) # delete raw file after upload
Shrine.plugin :remove_invalid # delete invalid files
Shrine.plugin :versions # create versions
Shrine.plugin :processing # process uploaded files
Shrine.plugin :validation_helpers # validation
Shrine.plugin :backgrounding # process in background job
Shrine.plugin :upload_endpoint # endpoint for XHR uploads
# Shrine.plugin :hooks # callbacks
Shrine.plugin :mongoid
