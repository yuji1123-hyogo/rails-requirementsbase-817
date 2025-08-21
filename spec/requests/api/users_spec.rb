require 'rails_helper'

RSpec.describe 'Api::Users', type: :request do
  describe 'POST /api/register' do
    let(:valid_params) do
      {
        user: {
          name: '田中太郎',
          email: 'tanaka@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context '正常系' do
      # 作成APIのテスト→レコードが一つ増えたことをテストする
      it 'ユーザー登録が成功する' do
        expect do
          post '/api/register', params: valid_params, as: :json
        end.to change(User, :count).by(1)

        # APIテストの基本→JSON内に期待通りのHTTPステータス＆データが含まれることをテストする
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body) # ハッシュへの変換
        expect(json['message']).to eq('ユーザーを登録しました')
        expect(json['data']['user']['name']).to eq('田中太郎')
        expect(json['data']['token']).to be_present
      end
    end

    context '異常系' do
      it 'バリデーションエラーの場合422を返す' do
        invalid_params = valid_params.dup
        invalid_params[:user][:email] = 'invalid-email'

        post '/api/register', params: invalid_params, as: :json

        # APIテストの基本→期待通りのHTTPステータスとJSONデータが含まれていることを確認する
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('ユーザー登録に失敗しました')
        expect(json['errors']).to be_present
      end

      it '重複メールアドレスの場合422を返す' do
        create(:user, email: 'tanaka@example.com')

        post '/api/register', params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # テスト対象(一つのエンドポイント)内で正常系と異常系を分ける
    describe 'GET /api/profile' do
      let(:user) { create(:user) }
      let(:token) { JWT.encode({ user_id: user.id }, ENV.fetch('JWT_SECRET_KEY')) }

      context '正常系' do
        it 'プロフィール取得が成功する' do
          get '/api/profile', headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['data']['user']['id']).to eq(user.id)
        end
      end

      context '異常系' do
        it '無効なトークンの場合401を返す' do
          get '/api/profile', headers: { 'Authorization' => 'Bearer invalid_token' }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'トークンがない場合401を返す' do
          get '/api/profile'
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
