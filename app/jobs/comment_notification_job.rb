class CommentNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(comment_id)
    comment = Comment.find(comment_id)

    Notification.create_notification_for_comment(comment)
  rescue StandardError => e
    Rails.logger.error "✖ CommentNotificationJob: 通知の作成に失敗しました"
    raise e
  end
end
