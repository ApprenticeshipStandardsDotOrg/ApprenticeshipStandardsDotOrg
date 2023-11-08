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

  def all_versions
    next_codes = get_next_versions(self, [])
    previous_codes = get_previous_versions(self, [])
    (next_codes + previous_codes).flatten.uniq
  end

  private

  def get_next_versions(onet, onet_codes = [])
    onet_codes << onet.next_versions.map(&:code)
    onet.next_versions.each do |next_onet|
      onet_codes = get_next_versions(next_onet, onet_codes.flatten)
    end
    onet_codes
  end

  def get_previous_versions(onet, onet_codes = [])
    onet_codes << onet.previous_versions.map(&:code)
    onet.previous_versions.each do |previous_onet|
      onet_codes = get_previous_versions(previous_onet, onet_codes.flatten)
    end
    onet_codes
  end
end
