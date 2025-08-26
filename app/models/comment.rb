class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: {
    scope: :book_id,
    message: 'この書籍はすでにコメントを投稿済みです'
  }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :rating_high, -> { order(rating: :desc) }
  scope :rating_low, -> { order(rating: :asc) }
  scope :by_rating, -> { where(rating: rating) if rating.present? }

  def self.average_rating_for_book(book_id)
    where(book_id: book_id).average(:rating).round(1)
  end

  def self.sorted_by(sort_key)
    case sort_key
    when 'oldest'
      oldest
    when 'rating_high'
      rating_high
    when 'rating_low'
      rating_low
    else
      recent
    end
  end
end
