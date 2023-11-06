class Onet < ApplicationRecord
  validates :title, presence: true
  validates :code, presence: true, uniqueness: {scope: :version}

  has_many :onet_mappings
  has_many :next_versions, through: :onet_mappings, source: :next_version_onet

  has_many :reverse_onet_mappings, class_name: "OnetMapping", foreign_key: :next_version_onet
  has_many :previous_versions, through: :reverse_onet_mappings, source: :onet

  CURRENT_VERSION = "2019".freeze

  scope :current_version, -> { where(version: Onet::CURRENT_VERSION) }

  def to_s
    "#{title} (#{code})"
  end
end
