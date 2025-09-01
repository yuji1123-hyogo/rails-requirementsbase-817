FactoryBot.define do
  factory :comment do
    association :book 
    association :user
    content { 'とても良い本でした' }
    rating { 5 }

    trait :good do
      content { '良い本でした。参考になりました。' }
      rating { 4 }
    end

    trait :average do
      content { '普通の本でした' }
      rating { 3 }
    end
  end
end
