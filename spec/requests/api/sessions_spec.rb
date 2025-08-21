require 'rails_helper'

RSpec.describe 'Api::Sessions', type: :request do
  describe 'POST /api/login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context '正常系' do
      it 'ログインに成功する' do
        post '/api/login', params: {
          email: user.email,
          password: 'password123'
        }, as: :json

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json['message']).to eq('ログインしました')
        expect(json['data']['user']['email']).to eq(user.email)
        expect(json['data']['token']).to be_present
      end
    end

    context '異常系' do
      it '無効なパスワードの場合401を返す' do
        post '/api/login', params: {
          email: user.email,
          password: 'wrongpassword'
        }, as: :json
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('メールアドレスまたはパスワードが正しくありません')
      end

      it '存在しないメールアドレスの場合401を返す' do
        post '/api/login', params: {
          email: 'nonexist@example.com',
          password: 'password123'
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/logout' do
    it 'ログアウトが成功する' do
      delete '/api/logout'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('ログアウトしました')
    end
  end
end
