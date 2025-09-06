class Tag < ApplicationRecord
  has_many :comment_tags, dependent: :destroy
  has_many :comments, through: :comment_tags
  has_many :books, -> { distinct }, through: :comments

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 20, minimum: 1 }
  validates :color, presence: true

  # enum定義
  enum color: {
    blue: 0,
    red: 1,
    green: 2,
    yellow: 3,
    purple: 4,
    gray: 5,
    indigo: 6,
    pink: 7
  }
  
  # 色コード定義
  COLOR_CODES = {
    blue: "#3B82F6",
    red: "#EF4444",
    green: "#10B981",
    yellow: "#F59E0B",
    purple: "#8B5CF6",
    gray: "#6B7280",
    indigo: "#6366F1",
    pink: "#EC4899"
  }.freeze

  scope :by_name, -> { order(:name) }
  scope :popular, -> { joins(:comment).group('tags.id').order('COUNT(comment.id) DESC') }
  scope :with_usage_count, -> {
    left_joins(:comment).group('tags.id').select('tags.*, COUNT(comment.id) as usage_count')
  }
  scope :popular_tags_for_book, -> (book){
      joins(:comments)
      .where(comments: { book_id: book.id})
      .group('tag.id')
      .order('COUNT(comment.id) DESC')
      .limit(5)
  }
  scope :search_by_name, -> (name) {
    return all unless name.present
    
    where('name LIKE ?', "%#{name}%")
  } 



  def color_code
    COLOR_CODES[color.to_sym] || COLOR_CODES[:blue]
  end

  def usage_count
    comment.count
  end

  def can_be_deleted?
    usage_count.zero
  end

  def self.popular_tags(limit = 10)
    with_usage_count
      .order('COUNT(comment.id) DESC')
      .limit(limit)
  end
end