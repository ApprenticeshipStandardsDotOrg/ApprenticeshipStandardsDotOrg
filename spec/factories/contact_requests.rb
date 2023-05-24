FactoryBot.define do
  factory :contact_request do
    name { "Foo Bar" }
    email { "foo@example.com" }
    message { "Here is a message" }
  end
end
