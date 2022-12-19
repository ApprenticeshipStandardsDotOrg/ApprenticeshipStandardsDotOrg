class StandardsImport < ApplicationRecord
  has_many_attached :files

  after_create :notify_admin

  def file_count
    files.count
  end

  private

  def notify_admin
    AdminMailer.new_standards_import(self).deliver_later
  end
end
