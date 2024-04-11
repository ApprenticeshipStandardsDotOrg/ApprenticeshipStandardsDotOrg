module Imports
  class Doc < Import
    has_one :pdf, as: :parent, dependent: :destroy, autosave: true
    has_one_attached :file
  end
end
