module CommentRenderable
  extend ActiveSupport::Concern

  private

  def comment_response(comment)
    {
      id: comment.id,
      content: comment.content,
      rating: comment.rating,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      user: user_response(comment.user),
      book_id: comment.book_id
    }
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name
    }
  end
end
