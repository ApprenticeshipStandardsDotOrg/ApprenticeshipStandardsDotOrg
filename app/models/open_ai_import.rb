class OpenAIImport < ApplicationRecord
  belongs_to :import
  belongs_to :occupation_standard, optional: true
  validates :response, presence: true
end
