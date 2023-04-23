class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :trackable

  enum :role, {basic: 0, admin: 1, converter: 2}

  has_many :api_keys, dependent: :destroy

  def create_api_access_token!
    api_key = api_keys.create
    APIBearerToken.create(user: self, api_key_id: api_key.id)
  end
end
