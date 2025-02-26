class OpenAIPrompt < ApplicationRecord
  validates :name, :prompt, presence: true
end
