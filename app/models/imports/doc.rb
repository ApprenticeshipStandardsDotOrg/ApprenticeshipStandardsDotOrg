module Imports
  class Doc < Import
    has_one :pdf, as: :parent, dependent: :destroy, autosave: true
    has_one_attached :file

    def process(**kwargs)
      output_pdf_path = ConvertDocToPdf.call(id, file)

      transaction do
        create_pdf!(
          file: File.open(output_pdf_path),
          public_document: public_document,
          metadata: metadata,
        )
        pdf.process(**kwargs)
        update!(
          processed_at: Time.current,
          processing_errors: nil,
          status: :completed,
        )
      end
    rescue ConvertDocToPdf::PdfConversionError => e
      update!(
        processed_at: nil,
        processing_errors: e.message,
        status: :needs_support,
      )
    end
  end
end
