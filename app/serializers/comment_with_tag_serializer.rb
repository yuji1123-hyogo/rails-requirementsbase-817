class CommentWithTagSerializer < ActiveModel::Serializer
  attributes :id, :content, :rating, :created_at, :updated_at, :book_id

  belongs_to :user, serializer: CommentUserSerializer
  has_many :tags, serializer: TagSerializer
end
