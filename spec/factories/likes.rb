FactoryBot.define do
  factory :like do
    association :user
    association :book
  end
end
