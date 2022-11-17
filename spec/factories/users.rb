FactoryBot.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com"}
    password { "passwordpassword" }

    factory :admin do
      role { "admin" }
    end
  end
end
