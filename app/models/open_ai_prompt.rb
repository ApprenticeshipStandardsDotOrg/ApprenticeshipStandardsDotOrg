class OpenAIPrompt < ApplicationRecord
  validates :name, :prompt, presence: true

  class << self
    def default
      first
    end
  end
end
