class Comment < ApplicationRecord
  after_create_commit :enqueue_notification_job

  belongs_to :user
  belongs_to :book
  has_many :comment_tags, dependent: :destroy
  has_many :tags, through: :comment_tags

  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: {
    scope: :book_id,
    message: 'この書籍はすでにコメントを投稿済みです'
  }
  validate :tags_count_limit

  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :rating_high, -> { order(rating: :desc) }
  scope :rating_low, -> { order(rating: :asc) }
  scope :by_rating, ->(rating) { where(rating: rating) if rating.present? }

  scope :filter_by_tag, ->(tag_names) {
    return all if tag_names.blank?

    tag_names = Array(tag_names).map(&:to_s)
    joins(:tags).where(tags: {name: tag_names}).distinct
  }

  # tagの取り付け(置き換え)
  def assign_tags(tag_names)
    return true if tag_names.blank?
    tag_names = Array(tag_names).map(&:to_s).uniq
    
    tags = tag_names.map do |tag_name|
      Tag.create_or_find_by(name: tag_name)
    end

    self.tags = tags
    true
  rescue StandardError => e
    errors.add(:tags, 'の更新に失敗しました')
    Rails.logger.error "タグの更新に失敗しました"
    false
  end

  def remove_tag(tag_id)
    comment_tags.find_by(tag_id: tag_id)&.destroy
  end

  def self.average_rating_for_book(book_id)
    where(book_id: book_id).average(:rating).to_f.round(1)
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

  private

  def enqueue_notification_job
    CommentNotificationJob.perform_later(id)
  end

  def tags_count_limit
    return unless tags.size > 5
    errors.add(:tags, 'は5個まで選択できます')
  end
end
