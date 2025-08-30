class Api::NotificationsController < ApplicationController
  def index
    notifications = current_user.notifications.includes(:actor, notifiable: :book).recent
  end
end
