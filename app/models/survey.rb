class Survey < ApplicationRecord
  validate :name, :email, :organization

  validates :email, format: {with: Devise.email_regexp, message: "must be a valid email"}
end
