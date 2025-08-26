class Book < ApplicationRecord
  has_many :users, through: :likes
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :commented_books, through: :comments, source: :book
  validates :title, presence: true, length: { minimum: 1, maximum: 200 }
  validates :author, presence: true, length: { minimum: 1, maximum: 100 }
  validates :isbn, uniqueness: true, allow_nil: true, length: { is: 13 }, numericality: { only_integer: true }
  validates :description, length: { maximum: 1000 }
  enum :genre, {
    fiction: 0,
    non_fiction: 1,
    mystery: 2,
    romance: 3,
    sci_fi: 4
  }
  scope :search_by_keyword, lambda { |keyword|
    return all if keyword.blank?

    # SQLインジェクション対策
    sanitized_keyword = sanitize_sql_like(keyword.strip)
    where(
      'title LIKE ? OR author LIKE ? OR description LIKE ?',
      "%#{sanitized_keyword}%",
      "%#{sanitized_keyword}%",
      "%#{sanitized_keyword}%"
    )
  }

  scope :filter_by_genre, lambda { |genre|
    where(genre: genre) if genre.present?
  }
  scope :sorted_by, lambda { |sort_key, order|
    allowed_key = %w[title author published_date created_at]
    sort_key = 'published_date' unless allowed_key.include?(sort_key)
    order = 'asc' unless %w[asc desc].include?(order&.downcase)
    order("#{sort_key} #{order}")
  }

  def self.book_search_and_filter(search_params)
    search_by_keyword(search_params[:search])
      .filter_by_genre(search_params[:genre])
      .sorted_by(search_params[:sort_key], search_params[:order])
  end
end
