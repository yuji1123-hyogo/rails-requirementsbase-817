class Api::LikesController < ApplicationController
  before_action :authenticate_user
  def index
    likes = current_user.likes.includes(:book).page(params[:page]).per(20)
    render_success(
      'お気に入り一覧を取得しました',
      {
        likes: likes.map { |like| like_response(like) },
        pagination: pagination_info(likes)
      }
    )
  end

  def create
    book = Book.find(params[:book_id])
    like = current_user.likes.build(book: book)
    if like.save
      render_success('書籍をお気に入り登録しました', { like: like_response(like) }, :created)
    elsif like.errors[:user_id].any?
      render_error('すでにお気に入り登録済みです', ['この書籍はお気に入り登録されています'], :conflict)
    else
      render_error('お気に入り登録に失敗しました', book.errors, :bad_request)
    end
  rescue ActiveRecord::RecordNotFound
    render_error(
      '書籍が見つかりません', ['指定された書籍は存在しません'], :not_found
    )
  end

  def destroy
    like = current_user.like.find_by!(book_id: params[:book_id])
    like.destroy!
    head :no_content
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
      title: book.title,
      author: book.author,
      genre: book.genre,
      published_date: book.published_date
    }
  end
end
