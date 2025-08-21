class ApplicationController < ActionController::API
  include JwtConcern

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
end
