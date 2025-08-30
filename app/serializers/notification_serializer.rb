class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :notification_type, :message, :read, :created_at, :notifiable_info

  def notifiable_info
    case object.notifiable_type
    when 'Comment'
      comment = object.notifiable
      {
        type: 'Comment',
        id: comment.id,
        book_id: comment.book_id,
        book_title: comment.book.title,
        content_preview: truncate_content(comment.content)
      }
    else
      {
        type: object.notifiable_type,
        id: object.notifiable.id
      }
    end

    private

    def truncate_content(content)
      content.length > 50 ? "#{content[0..50]}..." : content
    end
  end
end
