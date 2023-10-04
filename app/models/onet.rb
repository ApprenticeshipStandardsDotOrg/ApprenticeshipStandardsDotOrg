class Onet < ApplicationRecord
  validates :title, presence: true
  validates :code, presence: true, uniqueness: {scope: :version}

  CURRENT_VERSION = "2019".freeze

  def to_s
    "#{title} (#{code})"
  end
end
