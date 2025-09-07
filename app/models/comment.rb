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
    Rails.logger.debug "=== assign_tags 開始 ==="
    Rails.logger.debug "受け取った tag_names: #{tag_names.inspect}"

    return true if tag_names.blank?

    tag_names = Array(tag_names).map(&:to_s).uniq
    Rails.logger.debug "正規化後の tag_names: #{tag_names.inspect}"

    tags = tag_names.map do |tag_name|
      Rails.logger.debug "Tag.create_or_find_by を実行: #{tag_name}"
      tag = Tag.find_or_create_by(name: tag_name)
      Rails.logger.debug "生成または取得した Tag: #{tag.inspect}"
      tag
    end

    self.tags = tags
    Rails.logger.debug "関連付け後の self.tags: #{self.tags.map(&:attributes).inspect}"

    true
  rescue StandardError => e
    errors.add(:tags, "の更新に失敗しました: #{e.message}")
    Rails.logger.error "=== assign_tags エラー ==="
    Rails.logger.error "例外クラス: #{e.class}"
    Rails.logger.error "メッセージ: #{e.message}"
    Rails.logger.error "バックトレース: #{e.backtrace.take(10).join("\n")}"
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
