class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:show]

  def show
    render_success(
      'プロフィールを取得しました',
      { user: user_response(current_user) }
    )
  end

  def create
    user = User.new(user_params)
    if user.save
      token = jwt_encode({ user_id: user.id })
      render_success('ユーザーを登録しました', { user: user_response(user), token: token }, :created)
    else
      render_error('ユーザー登録に失敗しました', user.errors, :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      created_at: user.created_at
    }
  end
end
