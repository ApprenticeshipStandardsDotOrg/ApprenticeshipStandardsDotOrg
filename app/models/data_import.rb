class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user
  belongs_to :file_import

  has_one :occupation_standard

  validate :file_presence

  delegate :title, to: :occupation_standard, prefix: true, allow_nil: true

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "must be attached")
    end
  end
end
