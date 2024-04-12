module Imports
  class Pdf < Import
    has_one_attached :file

    enum :status, [
      :pending,
      :completed,
      :needs_support,
      :needs_human_review,
      :archived,
    ]
    enum courtesy_notification: [
      :not_required,
      :pending,
      :completed,
    ], _prefix: true

    def process
    end
  end
end
