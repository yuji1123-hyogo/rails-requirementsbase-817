class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :isbn, :genre, :published_date, :created_at, :updated_at

  has_many :comments, serializer: CommentSerializer
  has_many :users, serializer: UserSerializer
end
