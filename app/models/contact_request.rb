class ContactRequest < ApplicationRecord
  validates :name, :email, :message, presence: true

  after_commit :notify_admin, on: :create

  private

  def notify_admin
    AdminMailer.new_contact_request(self).deliver_later
  end
end
