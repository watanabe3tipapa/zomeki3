class Sys::Task < ApplicationRecord
  include Sys::Model::Base

  belongs_to :processable, polymorphic: true

  after_initialize :set_defaults
  after_destroy :destory_provider_job

  scope :queued_items, -> {
    where([
      arel_table[:state].eq('queued'),
      [arel_table[:state].eq('performing'), arel_table[:updated_at].lt(1.hours.ago)].reduce(:and)
    ].reduce(:or))
  }

  def publish_task?
    name == 'publish'
  end

  def close_task?
    name == 'close'
  end

  def state_queued?
    state == 'queued'
  end

  def enqueue_job
    return Sys::TaskJob.set(wait_until: process_at).perform_later(id)
  end

  private

  def set_defaults
    self.state ||= 'queued' if has_attribute?(:state)
  end

  def provider_job
    Delayed::Job.find_by(id: provider_job_id) if provider_job_id
  end

  def destory_provider_job
    provider_job.try(:destroy)
  end
end
