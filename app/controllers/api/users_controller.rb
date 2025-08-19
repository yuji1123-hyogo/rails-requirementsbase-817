class Api::UsersController < ApplicationController
  def create
    user = User.create(user_params)
    token = JWTService.encode(user.id)
    if user.save
      render_success('ユーザーを登録しました', { user: user, token: token }, :created)
    else
      render_error('ユーザー登録に失敗しました', user.error, :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
