require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    let(:user) { build(:user) }

    it '有効なユーザーが作成できる' do
      expect(user).to be_valid
    end
  end
end
