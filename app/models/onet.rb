class Onet < ApplicationRecord
  validates :title, presence: true
  validates :code, presence: true, uniqueness: {scope: :version}

  def to_s
    "#{title} (#{code})"
  end
end
