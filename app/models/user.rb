class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :trackable

  enum :role, [:basic, :admin]

  has_many :api_keys

  def create_api_access_token!
    api_key = api_keys.create
    APIBearerToken.create(user: self, key_identifier: api_key.id)
  end

  def destroy_api_key!(key_identifier)
    api_keys.where(id: key_identifier).destroy_all
  end
end
