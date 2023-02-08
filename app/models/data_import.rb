class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user

  validate :file_presence

  after_commit :process_data_import, on: :create

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "must be attached")
    end
  end

  def process_data_import
    ProcessDataImportJob.perform_later(self)
  end
end
