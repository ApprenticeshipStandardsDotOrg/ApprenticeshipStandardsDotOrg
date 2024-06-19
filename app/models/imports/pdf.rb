module Imports
  class Pdf < Import
    has_one_attached :file
    has_one_attached :redacted_pdf
    has_many :data_imports, -> { includes(:source_file, file_attachment: :blob) }, inverse_of: "import"
    has_many :associated_occupation_standards, -> { distinct }, through: :data_imports, source: :occupation_standard

    def self.recently_redacted(start_time: Time.zone.yesterday.beginning_of_day, end_time: Time.zone.yesterday.end_of_day)
      where(
        redacted_at: (
          start_time..end_time
        )
      )
    end

    def self.not_redacted
      includes(:redacted_pdf_attachment)
        .where(redacted_pdf_attachment: {id: nil})
    end

    def self.ready_for_redaction
      where(public_document: false).completed.not_redacted
    end

    def self.already_redacted
      includes(:redacted_pdf_attachment)
        .where.not(redacted_pdf_attachment: {id: nil})
    end

    def process(**_)
      update!(
        processed_at: Time.current,
        processing_errors: nil,
        status: :pending
      )
    end

    def redacted_pdf_url
      redacted_pdf&.blob&.url
    end

    def file_for_redaction
      redacted_pdf.attached? ? redacted_pdf : file
    end

    def pdf_leaf
      self
    end

    def cousins
      if docx_listing_root
        (docx_listing_root.pdf_leaves - [self]).sort_by(&:filename)
      else
        []
      end
    end

    # For Administrate
    def import
    end
  end
end
