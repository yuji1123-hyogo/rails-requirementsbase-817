class ApplicationController < ActionController::API
  # レスポンス構造の統一
  def render_success(message, data = {}, status = :ok)
    render json: { message: message, data: data }, status: status
  end

  def render_error(message, errors = {}, status = :bad_request)
    render json: { message: message, errors: errors }, status: status
  end

  def pagination_info(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end

  def authenticate_user
    header = request.headers['Authorization']
    token = header.split.last if header
    decoded = JWTService.decode(token)
    @current_user = User.find(decoded[:user_id]) if decoded
    @current_user
    render_error('認証に失敗しました', {}, :unauthorized) unless @current_user
  end
end
