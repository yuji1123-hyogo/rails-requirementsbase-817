FactoryBot.define do
  factory :tag do
    sequence(:name){|n| "タグ#{n}"}
    color {:blue}
  end
end