require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'バリデーション' do
    context '正常なデータの時' do
      let(:user) { create(:user) }
      let(:book) { create(:book) }
      let(:comment) { build(:comment, user: user, book: book) }

      it '有効なコメントが作成できる' do
        expect(comment).to be_valid
      end
    end

    context '異常系' do
      let(:user) { create(:user) }
      let(:book) { create(:book) }
      let(:comment) { build(:comment, user: user, book: book) }

      it 'contentが空の場合は無効' do
        comment.content = ''
        expect(comment).not_to be_valid
      end

      it 'contentが501文字以上の場合無効' do
        comment.content = 'a' * 501
        expect(comment).not_to be_valid
      end

      it 'ratingが5を超える場合無効' do
        comment.rating = 6
        expect(comment).not_to be_valid
      end

      it '同じユーザーが同じ本に複数コメントできない' do
        create(:comment, user: user, book: book)
        duplicate_comment = build(:comment, user: user, book: book)
        expect(duplicate_comment).not_to be_valid
      end
    end
  end

  describe 'クラスメソッド' do
    describe '.average_rating_for_book' do
      let(:book) { create(:book) }
      let(:taro) { create(:user) }
      let(:alice) { create(:user) }
      let(:bob) { create(:user) }

      context 'コメントがある場合' do
        before(:each) do
          create(:comment, book: book, user: taro, rating: 5)
          create(:comment, book: book, user: alice, rating: 4)
          create(:comment, book: book, user: bob, rating: 3)
        end

        it '平均評価を取得できる' do
          expect(Comment.average_rating_for_book(book.id)).to eq(4.0)
        end
      end

      context 'コメントがない場合' do
        it '0.0を返す' do
          expect(Comment.average_rating_for_book(book.id)).to eq(0.0)
        end
      end
    end
  end
end
