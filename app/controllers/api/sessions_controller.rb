class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      token = jwt_encode({ user_id: user.id })
      render_success('ログインしました', { user: user_response(user), token: token }, :created)
    else
      render_error('メールアドレスまたはパスワードが正しくありません', ['メールアドレスまたはパスワードが正しくありません'], :unauthorized)
    end
  end

  def destroy
    render_success('ログアウトしました', {}, :ok)
  end

  private

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
