FactoryBot.define do
  factory :user do
    traits_for_enum :role, User.roles

    sequence(:email) { |n| "user#{n}@example.com" }
    password { "passwordpassword" }

    factory :admin do
      role { "admin" }
    end
  end
end
