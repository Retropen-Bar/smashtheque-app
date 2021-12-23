class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # v0: only with no arguments
  def self.perform_later_if_needed
    perform_later if already_enqueued_job.nil?
  end

  protected

  def self.already_enqueued_job
    queue = Sidekiq::Queue.new(queue_name)
    queue.each do |job|
      return job if ((job.args || [])[0] || {})['job_class'] == self.to_s
    end
    nil
  end

end
