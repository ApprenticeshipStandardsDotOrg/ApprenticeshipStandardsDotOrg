class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user
  belongs_to :file_import

  belongs_to :occupation_standard, optional: true

  validate :file_presence

  delegate :title, to: :occupation_standard, prefix: true, allow_nil: true

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "must be attached")
    end
  end
end
