FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    association :actor, factory: :user
    association :notifiable, factory: :comment
    notification_type { :comment_on_book }
    message { "#{actor.name}さんがお気に入りの書籍「#{notifiable.book.title}」にコメントしました"}
    read { false }

    trait :read do
      read { true }
    end
  end
end
