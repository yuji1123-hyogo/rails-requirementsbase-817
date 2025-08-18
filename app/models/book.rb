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
    if keyword.blank?
      all
    else
      where('title LIKE :kw OR author LIKE :kw OR description LIKE :kw', kw: "%#{keyword}%")
    end
  }
  scope :published_between, lambda { |from_year, to_year|
    scope = all
    scope = scope.where('published_date >= from_year', from_year) if from_year.present?
    scope = scope.where('published_date =< to ', to_year) if to_year.present?
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
