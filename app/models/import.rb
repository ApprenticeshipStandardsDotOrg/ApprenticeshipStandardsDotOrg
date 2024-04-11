class Import < ApplicationRecord
  belongs_to :parent, polymorphic: true
end
