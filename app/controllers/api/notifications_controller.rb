class Api::NotificationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_notification, only: [:show, :mark_as_read]

  def index
    notifications = current_user.notifications.includes(:actor, :notifiable)
                                .filter(params)
                                .recent.page(params[:page]).per(20)
    unread_count = current_user.notifications.unread.size

    render_success(
      '通知一覧を取得しました',
      {
        notifications: ActiveModelSerializers::SerializableResource.new(
          notifications, each_serializer: NotificationSerializer
        ),
        unread_count: unread_count,
        pagination: pagination_info(notifications)
      }
    )
  end

  def show
    render_success(
      '通知を取得しました',
      { notification: NotificationSerializer.new(@notification) }
    )
  end

  def mark_as_read
    @notification.update!(read: true)
    render_success(
      '通知を既読しました',
      { notification: NotificationSerializer.new(@notification) }
    )
  end

  def mark_all_as_read
    update_count = current_user.notifications.unread.update_all(
      read: true,
      updated_at: Time.current
    )

    render_success(
      "#{update_count}件の通知を既読にしました",
      { update_count: update_count}
    )
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('通知が見つかりません',[],:not_found)
  end
end
