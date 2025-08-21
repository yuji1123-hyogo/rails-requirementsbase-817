class Api::LikesController < ApplicationController
  before_action :authenticate_user
  def index
    render_success('お気に入り一覧を取得しました', {
                     likes: like.map { |like| like_response(like) }
                   }, :oks)
  end

  def create
    book = Book.find(params[:book_id])
    if book
      @current_user.favorite_books << book
    else
      render_error('お気に入り登録に失敗しました', book.errors, :bad_request)
    end
  end

  def destroy
    favorite = @current_user.favorite_books(book_id: params[:book_id])
    if favorite
      render_success('お気に入りを解除しました', {}, :ok)
    else
      render_error('お気に入り解除に失敗しました', favorite.errors, :bad_request)
    end
  end

  private

  def like_response(like)
    {
      id: like.id,
      user_id: like.user_id,
      book_id: like.book_id,
      created_at: like.created_at,
      book: book_response(like.book)
    }
  end

  def book_response(book)
    {
      id: book.id,
      title: like.book.title,
      author: like.book.author,
      genre: like.book.genre,
      published_date: like.book.published_date
    }
  end
end
