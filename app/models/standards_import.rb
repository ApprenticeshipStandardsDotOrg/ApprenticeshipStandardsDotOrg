class StandardsImport < ApplicationRecord
  has_many_attached :files

  after_commit :create_source_files!

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

  def create_source_files!
    files.each do |file|
      Rails.error.handle do
        SourceFile.find_or_create_by!(active_storage_attachment_id: file.id)
      end
    end
  end
end
