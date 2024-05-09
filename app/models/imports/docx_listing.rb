module Imports
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
  end
end
