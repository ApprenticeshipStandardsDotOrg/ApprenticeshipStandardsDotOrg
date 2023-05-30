class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :trackable

  enum :role, {basic: 0, admin: 1, converter: 2}

  has_many :api_keys, dependent: :destroy

  def create_api_access_token!
    api_key = api_keys.create
    APIBearerToken.create(user: self, api_key_id: api_key.id)
  end

  # We need to override this to allow User creation without password
  def password_required?
    if new_record?
      false
    else
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
  end
end
