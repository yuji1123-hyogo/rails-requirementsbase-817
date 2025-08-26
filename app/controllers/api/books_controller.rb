class Api::BooksController < ApplicationController
  def index
    books = Book.book_search_and_filter(search_params)
    books = books.page(params[:page]).per(20)
    serialized_books = ActiveModelSerializers::SerializableResource.new(
      books,
      each_serializer: BookSerializer
    )
    render_success('書籍一覧を取得しました', { books: serialized_books, pagination: pagination_info(books) })
  end

  def show
    book = Book.find(params[:id])
    render_success('書籍を取得しました', { book: BookSerializer.new(book) }, :ok)
  rescue ActiveRecord::RecordNotFound
    render_error('書籍の取得に失敗しました', {}, :not_found)
  end

  def create
    book = Book.new(book_params)
    if book.save
      render_success('書籍を登録しました', { book: BookSerializer.new(book) }, :created)
    else
      render_error('書籍の登録に失敗しました', book.errors, :unprocessable_entity)
    end
  end

  def update
    book = Book.find(params[:id])
    if book.update(book_params)
      render_success('書籍を更新しました', { book: BookSerializer.new(book) })
    else
      render_error('書籍の更新に失敗しました', book.errors, :unprocessable_entity)
    end
  rescue ActiveRecord::RecordNotFound
    render_error('書籍が見つかりません', {}, :not_found)
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
    params.require(:book).permit(:title, :author, :isbn, :published_date, :description, :genre)
  end

  def search_params
    params.permit(
      :search,
      :genre, # ジャンルフィルタ
      :from_year,    # 出版年範囲（開始）
      :to_year,      # 出版年範囲（終了）
      :sort_key, # ソートキー
      :order # ソート順序
    )
  end
end
