module JwtConcern
  extend ActiveSupport::Concern

  private

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, ENV.fetch('JWT_SECRET_KEY', nil), 'HS256')
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, ENV.fetch('JWT_SECRET_KEY', nil), true, { algorithm: 'HS256' })[0]
    ActiveSupport::HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    render_unauthorized
    nil
  end

  def authenticate_user
    token = extract_token_from_header
    puts "☑☑token:#{token}"
    puts "☑☑jwt_secret_key:#{ENV.fetch('JWT_SECRET_KEY', nil)}"
    return render_unauthorized unless token

    decode_and_find_user(token)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "User not found: #{e.message}"
    render_unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    header&.split&.last
  end

  def decode_and_find_user(token)
    @decoded = jwt_decode(token)
    puts "☑☑@decoded#{@decoded}"
    @current_user = User.find(@decoded[:user_id]) if @decoded
    puts "☑@current_user#{@current_user}"
    @current_user
  end

  def render_unauthorized
    render json: {
      message: '認証が必要です',
      errors: ['ログインしてください']
    }, status: :unauthorized
  end
end
