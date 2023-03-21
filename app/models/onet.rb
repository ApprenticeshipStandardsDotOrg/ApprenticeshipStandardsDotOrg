class Onet < ApplicationRecord
  validates :name, :code, presence: true
  validates :code, uniqueness: true

  def to_s
    "#{name} (#{code})"
  end
end
