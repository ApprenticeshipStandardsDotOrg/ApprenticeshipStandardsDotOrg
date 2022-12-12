class StandardsImport < ApplicationRecord
  has_many_attached :files

  after_create :notify_admin

  private

  def notify_admin
    AdminMailer.new_standards_import(self).deliver_later
  end
end
