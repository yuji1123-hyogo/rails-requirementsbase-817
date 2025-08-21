module JsonWebToken
  extend ActiveSupport::Concern

  private

  def authenticate_user
    header = request.headers['Authorization']
    token = header.split.last if header
    return render_unauthorized('認証トークンが必要です') unless token

    decoded = decode(token)
    current_user = User.find(decoded[:user_id]) if decoded
    current_user
  rescue ActiveRecord::RecordNotFound => e
    render_unauthorized('無効なユーザーです')
  rescue JWT::DecodeError => e
    render_unauthorized('無効なトークンです')
  end

  def render_unauthorized
    render json: {
      message: '認証が必要です',
      errors: ['ログインしてください']
    }, status: :unauthorized
  end
end
