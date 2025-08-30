class FavoriteNotificationJob < ApplicationJob
  queue_as :default

  def perform(like)
    like = Favorite.find(like.id)
    Notification.create!(
      recipient: like.book.user,
      actor: like.user,
      notification_type: 'like_notification',
      notifiable: like.book
    )
  end
end
