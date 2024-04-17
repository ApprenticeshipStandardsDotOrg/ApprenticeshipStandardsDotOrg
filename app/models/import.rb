class Import < ApplicationRecord
  belongs_to :parent, polymorphic: true

  enum :status, [
    :pending,
    :completed,
    :needs_support,
    :needs_human_review,
    :archived,
    :needs_backend_support,
  ]
  enum courtesy_notification: [
    :not_required,
    :pending,
    :completed,
  ], _prefix: true
end
