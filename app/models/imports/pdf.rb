module Imports
  class Pdf < Import
    has_one_attached :file
    has_many :data_imports

    def process(**_)
      update!(
        processed_at: Time.current,
        processing_errors: nil,
        status: :pending
      )
    end

    def filename
      file.blob.filename.to_s
    end
  end
end
