require 'rails_helper'

RSpec.describe "Api::Notifications", type: :request do
  let(:recipient){ create(:user) }
  let(:actor){ create(:user) }
  let(:book){ create(:book) }
  let(:comment){ create(:comment, book: book, user: actor)}
  let(:token){ JWT.encode({user_id: recipient.id}, ENV.fetch('JWT_SECRET_KEY'),'HS256')}
  let(:auth_headers){{'Authorization' => "Bearer #{token}"}}

  describe 'GET /api/notifications' do
    context '認証済みユーザー' do
      before do
        @unread_notification = create(:notification, recipient: recipient, actor: actor, notifiable: comment )
        @read_notification = create(:notification, :read, recipient: recipient, actor: actor, notifiable: comment )
      end

      it 'ステータス200を返す' do
        get '/api/notifications', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it '通知一覧を返す' do
        get '/api/notifications', headers: auth_headers

        json = JSON.parse(response.body)
        notification_ids = json['data']['notifications'].map { |notification| notification['id'] }
        expect(notification_ids).to include(@unread_notification.id, @read_notification.id)
      end

      it '正しい未読件数を返す' do
        get '/api/notifications', headers: auth_headers

        json = JSON.parse(response.body)
        expect(json['data']['unread_count']).to eq(1)
      end

      it 'ページネーション情報を含む' do
        get '/api/notifications', headers: auth_headers

        json = JSON.parse(response.body)

        pagination = json['data']['pagination']

        expect(pagination).to include(
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 2,
          'per_page' => 20
        )
      end

      it 'フィルターが正しく動作する' do
        get '/api/notifications?unread=true', headers: auth_headers

        json = JSON.parse(response.body)
        notifications = json['data']['notifications']
        expect(notifications.size).to eq(1)
        notification_ids = notifications.map { |notification| notification['id'] }
        expect(notification_ids).not_to include(@read_notification.id)
        expect(notification_ids).to include(@unread_notification.id)
      end
    end

    context '未認証ユーザー' do
      it 'ステータス401を返す' do
        get '/api/notifications'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/notifications/:id' do
    let(:notification){ create(:notification, recipient: recipient, actor: actor, notifiable: comment)}

    context '認証済みユーザー' do
      it 'ステータス200を返す' do
        get "/api/notifications/#{notification.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it '通知の詳細情報を返す' do
        get "/api/notifications/#{notification.id}", headers: auth_headers
        json = JSON.parse(response.body)

        notification_data = json['data']['notification']
        expect(notification_data['id']).to eq(notification.id)
      end

      context '存在しない通知の場合' do
        it 'ステータス404を返す' do
          get "/api/notifications/99999999", headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context '未認証ユーザー' do
      it 'ステータス401を返す' do
        get "/api/notifications/#{notification.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/notifications/:id/mark_as_read' do
    let!(:notification) { create(:notification, recipient: recipient, actor: actor, notifiable: comment, read: false)}

    context '認証済みユーザー' do
      it 'ステータス200を返す' do
        patch "/api/notifications/#{notification.id}/mark_as_read", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it '通知が既読になる' do
        patch "/api/notifications/#{notification.id}/mark_as_read", headers: auth_headers

        notification.reload
        expect(notification.read).to be_truthy
      end

      it '既読後の通知情報を返す' do
        patch "/api/notifications/#{notification.id}/mark_as_read", headers: auth_headers

        json = JSON.parse(response.body)
        expect(json['data']['notification']).to include(
          'id' => notification.id,
          'read' => true
        )
      end
    end

    context '未認証ユーザーの場合' do
      it 'ステータス401を返す' do
         patch "/api/notifications/#{notification.id}/mark_as_read"
         expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'PATCH /api/notifications/mark_all_as_read' do
      context '認証済みユーザー' do
        before do
          @unread_notifications = create_list(:notification, 3, recipient: recipient, actor: actor, notifiable: comment, read: false)
          @read_notification = create(:notification, :read, recipient: recipient, actor: actor, notifiable: comment)
        end

        it 'ステータス200を返す' do
          patch '/api/notifications/mark_all_as_read', headers: auth_headers
          expect(response).to have_http_status(:ok)
        end

        it '自分の未読通知がすべて既読になる' do
          patch '/api/notifications/mark_all_as_read', headers: auth_headers

          @unread_notifications.each(&:reload)
          expect(@unread_notifications.all?(&:read)).to be_truthy
        end

        it '更新件数を返す' do
          patch '/api/notifications/mark_all_as_read', headers: auth_headers

          json = JSON.parse(response.body)
          expect(json['data']['update_count']).to eq(4)
        end
      end

      context '未認証ユーザー' do
        it 'ステータス401を返す' do
          patch '/api/notifications/mark_all_as_read'
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
