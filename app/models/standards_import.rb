class StandardsImport < ApplicationRecord
  has_many_attached :files
  has_many :imports, as: :parent, dependent: :destroy

  enum courtesy_notification: [:not_required, :pending, :completed], _prefix: true

  validates :email, :name, presence: true, unless: -> { courtesy_notification_not_required? }
  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  class << self
    def manual_submissions_in_need_of_courtesy_notification(email: nil)
      imports = StandardsImport.courtesy_notification_pending
      if email.present?
        imports = imports.where(email: email)
      end
      imports.select do |import|
        import.has_converted_source_file_in_need_of_notification?
      end
    end
  end

  def import_root
    self
  end

  def source_files
    files
      .includes(source_file: {active_storage_attachment: :blob})
      .order("active_storage_blobs.filename")
      .map(&:source_file)
      .compact
  end

  def has_converted_source_file_in_need_of_notification?
    source_files_in_need_of_notification.any?
  end

  def source_files_in_need_of_notification
    if courtesy_notification_pending?
      source_files.select { |source_file| source_file.needs_courtesy_notification? }
    else
      StandardsImport.none
    end
  end

  def has_notified_uploader_of_all_conversions?
    source_files.count == source_files.count { |source_file| source_file.courtesy_notification_completed? }
  end

  def file_count
    files.count
  end

  def url
    files&.last&.url
  end

  def notify_admin
    AdminMailer.new_standards_import(self).deliver_later
  end
end
