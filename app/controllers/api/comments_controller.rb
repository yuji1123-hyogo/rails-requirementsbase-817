class Api::CommentsController < ApplicationController
  include CommentRenderable

  before_action :authenticate_user, only: %i[create update destroy]

  def index
    comments = @book.comments.includes(:user)
                    .sort_by(params[:sort])
                    .by_rating(params[:rating])
                    .page(params[:page]).per(20)
    book_stats = {
      average_rating: Comment.average_rating_for_book(@book.id),
      total_comments: @book.comments.count
    }
    render_success(
      'コメント一覧を取得しました',
      {
        comments: comments.map { |comment| comment_response(comment) },
        pagination: pagination_info(comments),
        book_stats: book_stats
      }
    )
  end

  def create
    comment = @book.comments.build(comment_params.merge(user: current_user))
    if comment.save
      render_success(
        'コメントを作成しました',
        { comment: comment_response(comment) },
        :created
      )
    else
      render_error(
        'コメントの投稿に失敗しました',
        comment.errors,
        :unprocessable_entity
      )
    end
  end

  def update
    if @comment.update(comment_params)
      render_success(
        'コメントを更新しました',
        { comment: comment_response(@comment) }
      )
    else
      render_error(
        'コメントの更新に失敗しました',
        comment.errors,
        :unprocessable_entity
      )
    end
  end

  def destroy
    @comment.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render_error('コメントの削除に失敗しました', {}, :unprocessable_entity)
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  rescue ActiveRecord::RecordNotFound
    render_error('書籍が見つかりません', ['指定された書籍は存在しません'], :not_found)
  end

  def set_comment
    @comment = Comment.find(params[:id])
    @book = @comment.book
  rescue ActiveRecord::RecordNotFound
    render_error('コメントが見つかりません', ['指定されたコメントは存在しませんん'], :not_found)
  end

  def ensure_owner
    return if @comment.user == current_user

    render_error('権限がありません', ['自分のコメントのみ編集・削除できます'], :forbidden)
  end

  def comment_params
    params.require(:comment).permit(:content, :rating)
  end
end
