class Book < ApplicationRecord
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
      'title ILIKE ? OR author ILIKE ? OR description ILIKE ?',
      "%#{sanitized_keyword}%",
      "%#{sanitized_keyword}%",
      "%#{sanitized_keyword}%"
    )
  }
  scope :published_between, lambda { |from_year, to_year|
    scope = all
    scope = scope.where('published_date >= ?', from_year) if from_year.present?
    scope = scope.where('published_date =< ? ', to_year) if to_year.present?
    scope
  }
  scope :filter_by_genre, lambda { |genre|
    where(genre: genre) if genre.present?
  }
  scope :sorted_by, lambda { |sort_key, order|
    allowed_key = %w[title author published_date created_at]
    order(:published_date) if sort_key.blank?
    order(:published_date) if allowed_key.include?(sort_key)
    order("#{sort_key} #{order}")
  }

  def self.book_search_and_filter(search_params)
    books = Book.all
    books = books.search_by_keyword(search_params[:search])
    books = books.published_between(search_params[:from_year], search_params[:to_year])
    books = books.filter_by_genre(search_params[:genre])
    books.sorted_by(search_params[:sort_key], search_params[:order])
  end
end
