module Imports
  class Pdf < Import
    has_one_attached :file

    def process(**_)
      update!(
        processed_at: Time.current,
        processing_errors: nil,
        status: :completed
      )
    end
  end
end
