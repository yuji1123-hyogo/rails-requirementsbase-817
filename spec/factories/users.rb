FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "ユーザー#{n}" }
    sequence(:email) { |n| "user#{n}@example" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :invalid_email do
      email { 'invalid-email' }
    end

    trait :weak_password do
      password { '123' }
      password_confirmation { '123' }
    end
  end
end
