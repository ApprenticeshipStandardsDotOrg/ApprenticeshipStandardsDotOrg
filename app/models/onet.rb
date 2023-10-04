class Onet < ApplicationRecord
  validates :title, :code, presence: true
  validates :code, uniqueness: true

  def to_s
    "#{title} (#{code})"
  end
end
