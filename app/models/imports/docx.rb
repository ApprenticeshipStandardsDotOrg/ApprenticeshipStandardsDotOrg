module Imports
  class Docx < Import
    has_one :pdf, as: :parent, dependent: :destroy, autosave: true
    has_one_attached :file

    def process(**kwargs)
      output_pdf_path = ConvertDocToPdf.call(id, file)

      transaction do
        create_pdf!(
          file: File.open(output_pdf_path),
          public_document: public_document,
          metadata: metadata,
          courtesy_notification: courtesy_notification,
          assignee: assignee
        )
        pdf.process(**kwargs)
        update!(
          processed_at: Time.current,
          processing_errors: nil,
          status: :archived
        )
      end
    rescue => e
      update!(
        processed_at: nil,
        processing_errors: e.message,
        status: :needs_backend_support
      )
      raise
    end

    def pdf_leaf
      pdf
    end
  end
end
