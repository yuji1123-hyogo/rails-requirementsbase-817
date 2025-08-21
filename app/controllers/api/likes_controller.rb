class Api::LikesController < ApplicationController
  before_action :authenticate_user
  def index
    render_success('お気に入り一覧を取得しました', {
                     likes: like.map { |like| like_response(like) }
                   }, :oks)
  end

  def create
    book = Book.find(params[:book_id])
    like = current_user.likes.build(book: book)
    if like.save
      render_success('書籍をお気に入り登録しました', { like: like_response(like) }, :created)
    elsif like.errors[:user_id].any?
      render_error('すでにお気に入り登録済みです', ['この書籍はお気に入り登録されています'])
    else
      render_error('お気に入り登録に失敗しました', book.errors, :bad_request)
    end
  rescue ActiveRecord::RecordNotFound
    render_error(
      '書籍が見つかりません', ['指定された書籍は存在しません'], :not_found
    )
  end

  def destroy
    like = @current_user.favorite_books.find_by!(book_id: params[:book_id])
    if like.destroy
      render_success('お気に入りを解除しました', {}, :ok)
    else
      render_error('お気に入り解除に失敗しました', like.errors, :bad_request)
    end
  rescue ActiveRecord::RecordNotFound
    render_error(
      'お気に入りが見つかりません',
      ['指定された書籍はお気に入り登録されていません'],
      :not_found
    )
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
