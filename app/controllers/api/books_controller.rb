class Api::BooksController < ApplicationController
  def index
    books = Book.page(params[:page]).per(20)
    render_success("書籍一覧を取得しました", {books: books, pagination: pagination_info(books)})
  end

  def show
    book = Book.find(params[:id])
    render_success('書籍を取得しました', { book: book }, :ok)
  rescue ActiveRecord::RecordNotFound
    render_error('書籍の取得に失敗しました', {}, :not_found)
  end

  def create
    book = Book.new(book_params)
    if book.save
      render_success('書籍を登録しました', { book: book }, :created)
    else
      render_error('書籍の登録に失敗しました', book.errors, :unprocessable_entity)
    end
  end

  def update
    book = Book.find(params[:id])
    if book.update(book_params)
      render_success('書籍を更新しました', { book: book })
    else
      render_error('書籍の更新に失敗しました', book.errors, :unprocessable_entity)
    end
  rescue ActiveRecord::RecordNotFound
    render_error('書籍が見つかりません', :not_found)
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render_error('書籍が見つかりません', {}, :not_found)
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :isbn, :published_date, :description ,:genre)
  end
end