class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user

  validate :file_presence

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "Must upload file")
    end
  end
end
