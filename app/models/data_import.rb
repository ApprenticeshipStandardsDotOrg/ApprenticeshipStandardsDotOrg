class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user

  has_one :occupation_standard

  validate :file_presence

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "must be attached")
    end
  end
end
