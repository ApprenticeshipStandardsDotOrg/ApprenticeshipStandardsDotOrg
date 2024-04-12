module Imports
  class Pdf < Import
    has_one_attached :file

    def process
    end
  end
end
