class Import < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :assignee, class_name: "User", optional: true
  has_many :data_imports, -> { none }, inverse_of: "import"

  enum :status, [
    :pending,
    :completed,
    :needs_support,
    :needs_human_review,
    :archived,
    :needs_backend_support,
    :unfurled
  ]
  enum courtesy_notification: [
    :not_required,
    :pending,
    :completed
  ], _prefix: true
end
