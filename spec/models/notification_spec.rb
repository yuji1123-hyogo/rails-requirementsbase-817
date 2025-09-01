require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'アソシエーション' do
    it { should belong_to(:recipient).class_name('User') }
    it { should belong_to(:actor).class_name('User') }
    it { should belong_to(:notifiable) }
  end

  describe 'バリデーション' do
    subject { build(:notification) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:notification_type)}
    it { should validate_length_of(:message).is_at_most(500)}
  end

  describe 'スコープ' do
    let(:recipient){ create(:user) }
    let(:actor){ create(:user) }
    let(:book){ create(:book) }
    let(:comment){ create(:comment, book: book, user: actor)}

    before do
      @read_notification = create(:notification, :read, notification_type: :comment_on_book, recipient: recipient, actor: actor, notifiable: comment)
      @unread_notification = create(:notification, read: false,notification_type: :comment_on_book,  recipient: recipient, notifiable: comment)

      @like_notification = create(:notification, :read, notification_type: :like_notification, recipient: recipient, actor: actor, notifiable: comment)
      @comment_on_book_notification = create(:notification, :read, notification_type: :comment_on_book, recipient: recipient, notifiable: comment)
      @comment_reply_notification = create(:notification, :read, notification_type: :comment_reply, recipient: recipient, notifiable: comment)
    end

    describe '.unread' do
      it '未読通知のみを返す' do
        expect(Notification.unread).to include(@unread_notification)
        expect(Notification.unread).not_to include(@read_notification)
      end
    end

    describe '.by_type' do
      it '指定したタイプの通知の実を返す' do
        expect(Notification.by_type('like_notification')).to include(@like_notification)
        expect(Notification.by_type('like_notification')).not_to include(@comment_on_book_notification)
        expect(Notification.by_type('like_notification')).not_to include(@comment_reply_notification)
      end
    end

    describe '.apply_filters' do
      context 'パラメータが空の場合' do
        it 'すべての通知を返す' do
          result = Notification.apply_filters({})
          expect(result).to contain_exactly(
            @read_notification,
            @unread_notification,
            @like_notification,
            @comment_on_book_notification,
            @comment_reply_notification
            )
        end
      end

      context 'unread: trueの場合' do
        it '未読の通知のみを返す' do
          result = Notification.apply_filters({ unread: true })
          expect(result).to contain_exactly(@unread_notification)
        end
      end

      context 'typeが指定された場合'do
        it 'そのタイプの通知のみを返す' do
         result = Notification.apply_filters({ type: 'comment_on_book' })
          expect(result).to contain_exactly(@unread_notification, @read_notification, @comment_on_book_notification)
        end
      end
    end
  end

  describe '.create_notification_for_comment' do
    let(:book) { create(:book)}
    let(:comment_author){ create(:user) }
    let(:like_user){ create(:user) }
    let(:comment){ create(:comment, book: book, user: comment_author)}

    # 書籍をお気に入り登録する
    before do
      create(:like, user: like_user, book: book)
    end

    it '書籍をお気に入り登録しているユーザーに通知を作成する' do
      notifications = Notification.create_notification_for_comment(comment)
      recipients = Notification.where(notifiable: comment).pluck(:recipient_id)
      expect(recipients).to include(like_user.id)
    end

    it 'コメント作成者には通知を作成しない' do
      notifications = Notification.create_notification_for_comment(comment)
      recipients = Notification.where(notifiable: comment).pluck(:recipient_id)
      expect(recipients).not_to include(comment_author.id)
    end
  end
end
