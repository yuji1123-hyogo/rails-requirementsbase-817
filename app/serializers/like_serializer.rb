# app/serializers/like_serializer.rb
class LikeSerializer < ActiveModel::Serializer
  attributes :id, :created_at

  belongs_to :book, serializer: BookSerializer
end
