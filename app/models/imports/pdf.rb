module Imports
  class Pdf < Import
    has_one_attached :file

    def process(**_)
    end
  end
end
