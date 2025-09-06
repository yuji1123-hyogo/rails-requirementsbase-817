class BookWithTagSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :isbn, :publish_date, :created_at, :updated_at, :popular_tags

  has_many :comments, serializer: CommentWithTagSerializer

  def popular_tags
    tags = Tag.joins(:comments)
              .where(comments:{book_id: object.id})
              .group('tags.id')
              .order('COUNT(comments.id) DESC')
              .limit(5)
    
    ActiveModelSerializers::SerializableResource.new(
      tags,
      each_serializer: TagSerializer
    ).as_json
  end
end
