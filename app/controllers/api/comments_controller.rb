class Api::CommentsController < ApplicationController
  before_action :authenticate_user, only: %i[create update destroy index]
  before_action :set_book, only: %i[create index]
  before_action :set_comment, only: %i[update destroy]
  before_action :ensure_owner, only: %i[update destroy]

  def index
    comments = @book.comments.includes(:user)
                    .sorted_by(params[:sort])
                    .by_rating(params[:rating])
                    .page(params[:page]).per(20)
    serialized_comments = ActiveModelSerializers::SerializableResource.new(
      comments,
      each_serializer: CommentSerializer
    ).as_json

    book_stats = {
      average_rating: Comment.average_rating_for_book(@book.id),
      total_comments: @book.comments.count
    }

    render_success(
      'コメント一覧を取得しました',
      {
        comments: serialized_comments,
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
        { comment: CommentSerializer.new(comment).as_json },
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
        { comment: CommentSerializer.new(@comment).as_json }
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
