class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  validates :message, presence: true, length: { maximum: 500}
  validates :notification_type, presence: true

  enum notification_type: {
    comment_on_book: 0,
    comment_reply: 1,
    like_notification: 2
  }

  scope :unread, -> { where(read: false) }
  scope :by_type, -> (type) {
    where(notification_type: type)
  }
  scope :recent, -> { order(created_at: :desc) }

  def self.create_notification_for_author_by_comment_on_book(comment)
    book = comment.book

    create!(
      recipient: book.author,
      actor: comment.user,
      notifiable: comment,
      notification_type: 'comment_on_book',
      message: "#{comment.user.name}さんがあなたの書籍[#{book.name}]にコメントしました"
    )
  end

  def self.create_notification_for_author_by_like_on_book(like)
    book = like.book

    create!(
      recipient: book.author,
      actor: like.user,
      notifiable: book,
      notification_type: 'like_notification',
      message: "#{like.user.name}さんがあなたの書籍[#{book}]をお気に入り登録しました"
    )
  end

  def self.filter(params)
    scope = all
    scope = scope.unread if params[:unread]
    scope = scope.by_type(params[:type]) if params[:type]
    scope
  end
end
