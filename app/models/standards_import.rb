class StandardsImport < ApplicationRecord
  has_many_attached :files

  after_commit :create_source_files

  enum courtesy_notification: [:not_required, :pending, :completed], _prefix: true

  def file_count
    files.count
  end

  def url
    files&.last&.url
  end

  def notify_admin
    AdminMailer.new_standards_import(self).deliver_later
  end

  private

  def create_source_files
    CreateSourceFilesJob.perform_later(self)
  end
end
