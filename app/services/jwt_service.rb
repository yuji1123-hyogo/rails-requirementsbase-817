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

  def render_unauthorized(message = '認証が必要です')
    render json: { message: message, errors: ['ログインしてください'] }, status: :unauthorized
  end
end
