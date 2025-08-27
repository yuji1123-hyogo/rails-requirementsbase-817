require 'rails_helper'

RSpec.describe 'Api::Comments', type: :request do
  describe 'POST /api/books/:book_id/comments' do
    context '認証済みユーザー' do
      let(:book) { create(:book) }
      let(:user) { create(:user) }
      let(:token) { JWT.encode({ user_id: user.id }, ENV.fetch('JWT_SECRET_KEY'), 'HS256') }

      def auth_headers(token = nil)
        token ? { 'Authorization' => "Bearer #{token}" } : {}
      end

      context '正常系' do
        let(:valid_params) do
          {
            comment: {
              content: 'とても良い本でした',
              rating: 5
            }
          }
        end

        it 'ステータス201を返す' do
          post "/api/books/#{book.id}/comments",
               params: valid_params,
               headers: auth_headers(token)

          expect(response).to have_http_status(:created)
        end

        it 'コメントが作成される' do
          expect do
            post "/api/books/#{book.id}/comments",
                 params: valid_params,
                 headers: auth_headers(token)
          end.to change(Comment, :count).by(1)
        end

        it '正しいレスポンス構造を返す' do
          post "/api/books/#{book.id}/comments",
               params: valid_params,
               headers: auth_headers(token)

          response_body = JSON.parse(response.body)
          expect(response_body['message']).to eq('コメントを作成しました')
          expect(response_body['data']['comment']).to include(
            'id' => be_a(Integer),
            'content' => valid_params[:comment][:content],
            'rating' => valid_params[:comment][:rating]
          )
        end
      end

      context '異常系' do
        let(:valid_params) do
          {
            comment: {
              content: 'とても良い本でした',
              rating: 5
            }
          }
        end

        it 'contentが空の場合422を返す' do
          invalid_params = valid_params.dup
          invalid_params[:comment][:content] = ''

          post "/api/books/#{book.id}/comments", params: invalid_params, headers: auth_headers(token)

          expect(response).to have_http_status(:unprocessable_entity)
          response_body = JSON.parse(response.body)
          expect(response_body['message']).to eq('コメントの投稿に失敗しました')
        end

        it 'ratingが6以上の時422を返す' do
          invalid_params = valid_params.dup
          invalid_params[:comment][:rating] = 6
          post "/api/books/#{book.id}/comments", params: invalid_params, headers: auth_headers(token)

          expect(response).to have_http_status(:unprocessable_entity)
          response_body = JSON.parse(response.body)
          expect(response_body['message']).to eq('コメントの投稿に失敗しました')
        end

        it '同じ本への重複コメントの場合422を返す' do
          create(:comment, user: user, book: book)

          post "/api/books/#{book.id}/comments", params: valid_params, headers: auth_headers(token)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context '未認証ユーザー' do
      let(:book) { create(:book) }
      let(:valid_params) do
        {
          comment: {
            content: 'とても良い本でした',
            rating: 5
          }
        }
      end

      it '401を返す' do
        post "/api/books/#{book.id}/comments", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/books/:book_id/comments' do
    context '認証済みユーザー' do
    end

    context '未認証ユーザー' do
    end
  end

  describe 'PUT /api/comments/:id' do
    context '認証済みユーザー' do
    end

    context '未認証ユーザー' do
    end
  end

  describe 'DELETE /api/comments/:id' do
    context '認証済みユーザー' do
    end

    context '未認証ユーザー' do
    end
  end
end
