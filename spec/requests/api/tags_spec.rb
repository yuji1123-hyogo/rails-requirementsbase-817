require 'rails_helper'

RSpec.describe "Api::Tags", type: :request do
  describe 'GET /api/tags' do
    let!(:tag1){ create(:tag,name: 'Ruby', color: :blue)}
    let!(:tag2){ create(:tag,name: 'Rails', color: :red)}
    let!(:tag3){ create(:tag,name: 'JavaScript', color: :yellow)}

    context '正常系' do
      let(:user) { create(:user) }
      let(:token) { JWT.encode({ user_id: user.id }, ENV.fetch('JWT_SECRET_KEY'), 'HS256') }

      def auth_headers(token = nil)
        token ? { 'Authorization' => "Bearer #{token}" } : {}
      end

      it 'ステータス200を返す' do
        get '/api/tags', headers: auth_headers(token)
        expect(response).to have_http_status(:ok)
      end

      it 'タグ一覧を返す' do
        get '/api/tags', headers: auth_headers(token)
         json = JSON.parse(response.body)

         expect(json['message']).to eq('タグ一覧を取得しました')
         expect(json['data']['tags']).to be_an(Array)
         expect(json['data']['tags'].length).to eq(3)
      end


      it '名前で部分一致検索ができる' do
        get '/api/tags', params: { search: 'Ru' }, headers: auth_headers(token)
        json = JSON.parse(response.body)

        expect(json['data']['tags'].length).to eq(1)
        expect(json['data']['tags'].first['name']).to eq('Ruby')
      end
    end

    context '異常系' do
      it '未認証の場合401を返す' do
        get '/api/tags'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
