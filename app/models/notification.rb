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

  def self.create_notification_for_comment(comment)
    book = comment.book
    actor = comment.user

    # お気に入り登録したユーザーに通知
    book.users.where.not(id: actor.id).find_each do |recipient|
      create!(
        recipient: recipient,
        actor: actor,
        notifiable: comment,
        notification_type: 'like_notification',
        message: "#{actor.name}さんがお気に入りの書籍「#{book.title}」にコメントしました"
      )
    end
  rescue StandardError => e
    Rails.logger.error "Notification creation failed: #{e.message}"
    raise e
  end

  def self.filter(params)
    scope = all
    scope = scope.unread if params[:unread]
    scope = scope.by_type(params[:type]) if params[:type]
    scope
  end
end
