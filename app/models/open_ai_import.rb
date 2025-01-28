class OpenAIImport < ApplicationRecord
  belongs_to :import
  belongs_to :occupation_standard
  validates :response, presence: true
end
