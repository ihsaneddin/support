begin; require 'sidekiq'; rescue LoadError; end

module Support::Uploadable
  class DeleteWorker

    if defined? Sidekiq

      include Sidekiq::Worker
      sidekiq_options :queue => Support.uploadable.sidekiq_queue, backtrace: Rails.env.development?? 20 : 1

    end


    def perform(data)
      # can use attacher object to manipulate record after processing
      # such as: attacher.record.update(published: false)
      attacher = Shrine::Attacher.delete(data)
    end
  end
end
