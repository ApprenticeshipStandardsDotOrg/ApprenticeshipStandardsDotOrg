module Imports
  class DocxListing < Import
    has_many :imports, as: :parent, dependent: :destroy, autosave: true
    has_one_attached :file

    def process(**_)
      # TODO
    end
  end
end
