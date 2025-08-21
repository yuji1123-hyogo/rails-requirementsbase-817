class Api::SessionsController < ApplicationController
  def create
    user = user.find_by(email: params[:email]&.downcase)
    if user&.authenticate_user(user.id)
      token = JWTService.encode(user_id: user.id)
      render_success('ログインしました', { user: user_response(user), token: token }, :created)
    else
      render_error('メールアドレスまたはパスワードが正しくありません', user.error, :unauthorized)
    end
  end

  def destroy
    render_success('ログアウトしました', {}, :ok)
  end

  private

  def login_params
    params.permit(:email, :password)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
