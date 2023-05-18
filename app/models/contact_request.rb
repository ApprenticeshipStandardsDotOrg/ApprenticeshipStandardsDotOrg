class ContactRequest < ApplicationRecord
  validates :name, :email, :message, presence: true
end
