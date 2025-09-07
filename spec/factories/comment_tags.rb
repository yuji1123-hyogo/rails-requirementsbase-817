FactoryBot.define do
  factory :comment_tag do
    association :comment
    association :tag
  end
end