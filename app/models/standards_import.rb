class StandardsImport < ApplicationRecord
  has_many_attached :files
  has_many :imports, as: :parent, dependent: :destroy

  enum courtesy_notification: [:not_required, :pending, :completed], _prefix: true

  validates :email, :name, presence: true, unless: -> { courtesy_notification_not_required? }
  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  class << self
    def manual_submissions_in_need_of_courtesy_notification(email: nil)
      standards_imports = StandardsImport.courtesy_notification_pending
      if email.present?
        standards_imports = standards_imports.where(email: email)
      end
      standards_imports.select do |standards_import|
        standards_import.has_converted_source_file_in_need_of_notification?
      end
    end
  end

  def import_root
    self
  end

  def has_converted_source_file_in_need_of_notification?
    source_files_in_need_of_notification.any?
  end

  def source_files_in_need_of_notification
    if courtesy_notification_pending?
      pdf_leaves.select { |pdf| pdf.needs_courtesy_notification? }
    else
      []
    end
  end

  def pdf_leaves
    imports.includes(:import).flat_map(&:pdf_leaves)
  end

  def has_notified_uploader_of_all_conversions?
    pdf_leaves.count == pdf_leaves.count { |pdf| pdf.courtesy_notification_completed?}
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
