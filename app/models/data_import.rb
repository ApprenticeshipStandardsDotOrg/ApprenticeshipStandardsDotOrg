class DataImport < ApplicationRecord
  has_one_attached :file

  belongs_to :user
  belongs_to :source_file

  belongs_to :occupation_standard, optional: true

  validate :file_presence
  validate :file_mime_type

  delegate :title, to: :occupation_standard, prefix: true, allow_nil: true
  delegate :filename, to: :file, allow_nil: true

  enum :status, [:pending, :importing, :completed]

  ACCEPTED_CONTENT_TYPES = %w[
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.ms-excel.sheet.macroEnabled.12
    application/vnd.oasis.opendocument.spreadsheet
    text/csv
  ]

  def related_occupation_standard(title)
    OccupationStandard
      .joins(data_imports: :source_file)
      .where.not(data_imports: {id: id})
      .where(source_files: {id: source_file_id})
      .first
  end

  private

  def file_presence
    unless file.attached?
      errors.add(:file, "must be attached")
    end
  end

  def file_mime_type
    if file.content_type && !file.content_type.in?(ACCEPTED_CONTENT_TYPES)
      errors.add(
        :file,
        :unacceptable_content_type,
        list: %w[.xlsx .xlsm .csv .ods].join(", ")
      )
    end
  end
end
