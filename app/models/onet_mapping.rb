class OnetMapping < ApplicationRecord
  belongs_to :onet
  belongs_to :next_version_onet, class_name: "Onet"

  validates :onet, uniqueness: {scope: :next_version_onet}
end
