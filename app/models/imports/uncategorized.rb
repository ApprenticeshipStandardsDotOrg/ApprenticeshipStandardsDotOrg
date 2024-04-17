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
        status: :completed
      )
    end

    def child_type(listing:)
      case filename_suffix
      in "doc"
        "Imports::Doc"
      in "docx" if listing
        "Imports::DocxListing"
      in "docx" if !listing
        "Imports::Docx"
      in "pdf"
        "Imports::Pdf"
      end
    end

    def filename_suffix
      file_attachment.filename.extension
    end
  end
end
