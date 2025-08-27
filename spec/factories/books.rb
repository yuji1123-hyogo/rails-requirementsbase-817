FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "書籍タイトル#{n}" }
    sequence(:author) { |n| "著者#{n}" }
    sequence(:isbn) { |n| n.to_s.rjust(13, '0') }
    description { 'これは素晴らしい本です' }
    genre { :fiction }
    published_date { 1.year.ago }

    trait :non_fiction do
      genre { :non_fiction }
      title { 'Rails開発入門' }
      author { 'Rails太郎' }
    end

    trait :mystery do
      genre { :mystery }
      title { '謎解き太郎' }
      author { 'ミステリー作家' }
    end

    trait :invalid_isbn do
      isbn { '123' }
    end
  end
end
