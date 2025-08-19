class Api::SessionsController < ApplicationController
  def create
    user = user.find_by(email: params[:email])
    token = JWTService.encode(user.id)
    if user.save
      render_success('ログインしました', { user: user, token: token }, :created)
    else
      render_error('ログアウトしました', user.error, :unprocessable_entity)
    end
  end

  def destroy
    render_success('ログアウトしました', {}, :ok)
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
