class NotificationActorSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar_url

  def avatar_url
    object.avatar_url
  end
end
