module Imports
  class Uncategorized < Import
    has_one_attached :file
    has_one :import, as: :parent, dependent: :destroy, autosave: true

    def process(**kwargs)
      transaction do
        create_child!(**kwargs)
        process_child(**kwargs)
        complete_processing
      end
    rescue => e
      update!(
        processed_at: nil,
        processing_errors: e.message,
        status: :needs_backend_support
      )
      raise
    end

    private

    DOCX_CONTENT_TYPE = Mime::Type.lookup_by_extension("docx").to_s
    DOC_CONTENT_TYPE = Mime::Type.lookup_by_extension("doc").to_s
    PDF_CONTENT_TYPE = Mime::Type.lookup_by_extension("pdf").to_s

    def create_child!(listing:)
      create_import!(
        status: :pending,
        assignee_id: assignee_id,
        public_document: public_document,
        courtesy_notification: courtesy_notification,
        metadata: metadata,
        file: file_blob,
        type: child_type(listing:)
      )
    end

    def process_child(**kwargs)
      import.process(**kwargs)
    end

    def complete_processing
      update!(
        processed_at: Time.current,
        processing_errors: nil,
        status: :archived,
      )
    end

    def child_type(listing:)
      case file_blob.content_type
      in DOC_CONTENT_TYPE
        "Imports::Doc"
      in DOCX_CONTENT_TYPE if listing
        "Imports::DocxListing"
      in DOCX_CONTENT_TYPE if !listing
        "Imports::Docx"
      in PDF_CONTENT_TYPE
        "Imports::Pdf"
      end
    end
  end
end
