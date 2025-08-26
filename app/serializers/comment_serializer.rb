class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :rating, :created_at, :update_at, :book_id

  belongs_to :user, serializer: UserSerializer
end
