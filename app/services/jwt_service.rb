class JWTService
  JWT_SECRET_KEY = ENV.fetch('JWT_SECRET_KEY')

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    ActiveSupport::HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end

  def self.authenticate_user
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

  def render_unauthorized(message = '認証が必要です')
    render json: { message: message, errors: ['ログインしてください'] }, status: :unauthorized
  end
end
