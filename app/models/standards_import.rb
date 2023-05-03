class StandardsImport < ApplicationRecord
  has_many_attached :files

  after_commit :notify_admin, on: :create

  def file_count
    files.count
  end

  def url
    files&.last&.url
  end

  private

  def notify_admin
    if ENV.fetch("ENABLE_STANDARDS_IMPORTS_NOTIFICATIONS", "false") == "true"
      AdminMailer.new_standards_import(self).deliver_later
    end
  end
end
