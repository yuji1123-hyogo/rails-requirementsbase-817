class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :avatar_url

  has_many :favorite_books, each_serialize: BookSerializer

  delegate :avatar_url, to: :object
end
