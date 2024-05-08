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
  end
end
