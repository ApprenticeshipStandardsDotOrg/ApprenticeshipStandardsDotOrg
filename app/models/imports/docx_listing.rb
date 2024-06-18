module Imports
  class NoPdfLeafError < NoMethodError
  end

  class DocxListing < Import
    has_many :imports, as: :parent, dependent: :destroy, autosave: true
    has_one_attached :file

    def process(**kwargs)
      transaction do
        DocxListingSplitter.split(id, file) do |file_names|
          file_names.each do |file_name|
            imports.create!(
              type: "Imports::Uncategorized",
              status: :unfurled,
              assignee_id: assignee_id,
              public_document: public_document,
              courtesy_notification: courtesy_notification,
              metadata: metadata,
              file: File.open(file_name)
            )
          end
        end
      end

      imports.each { _1.process(**kwargs) }

      update!(
        processed_at: Time.current,
        processing_errors: nil,
        status: :archived
      )
    rescue => e
      update!(
        processed_at: nil,
        processing_errors: e.message,
        status: :needs_backend_support
      )
      raise
    end

    def docx_listing_root
      self
    end

    def pdf_leaf
      raise Imports::NoPdfLeafError, "#{self.class.name} records do not have a PDF leaf"
    end

    def pdf_leaves
      imports.map(&:pdf_leaf)
    end

    # For Administrate
    def import
    end
  end
end
