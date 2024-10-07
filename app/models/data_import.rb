class DataImport < ApplicationRecord
  has_one_attached :file
  has_one :text_representation

  belongs_to :user, optional: true
  belongs_to :import, class_name: "Imports::Pdf", foreign_key: :import_id, optional: true

  belongs_to :occupation_standard, optional: true

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

  class << self
    def recent_uploads(start_time: Time.zone.yesterday.beginning_of_day, end_time: Time.zone.yesterday.end_of_day)
      where("created_at BETWEEN ? AND ?", start_time, end_time)
    end
  end

  def related_occupation_standard(title)
    OccupationStandard
      .joins(data_imports: :import)
      .where(occupation_standards: {title: title})
      .where.not(data_imports: {id: id})
      .where(imports: {id: import_id})
      .first
  end

  def to_text
    unless text_representation
      create_text_representation!(
        content: import.text
      )
    end

    text_representation.content
  end

  private

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
