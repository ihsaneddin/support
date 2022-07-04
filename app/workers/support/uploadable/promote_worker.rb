begin; require 'sidekiq'; rescue LoadError; end

module Support::Uploadable
  class PromoteWorker

    if defined? Sidekiq

      include Sidekiq::Worker
      sidekiq_options :queue => Support.uploadable.sidekiq_queue, retry: 1, backtrace: Rails.env.development?? 20 : 1

      sidekiq_retries_exhausted do |msg, ex|
        # destroy record if processing retries are exhausted
        record = args.first['record']
        record.first.constantize.find(record.last.to_i).destroy
      end
    end


    def perform(data)
      # can use attacher object to manipulate record after processing
      # such as: attacher.record.update(published: true)
      attacher = Shrine::Attacher.promote(data)
    end
  end
end
