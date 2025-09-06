class Api::TagController < ApplicationController
  before_action :set_tag, only: [:show, :destroy]


  def index
    tags = Tag.search_by_name(params[:search]).page(params[:page]).per(20)

    render_success(
      'タグ一覧を取得しました',
      {
        tags: ActiveModelSerializers::SerializableResource.new(
          tags,
          each_serializer: TagSerializer
        ),
        pagination: pagination_info(tags)
      }
    )
  end

  def show
    render_success(
      'タグを取得しました',
      {
        tag: TagSerializer.new(@tag),
        usage_count: @tag.usage_count
      }
    )
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('タグが見つかりません', {}, :not_found)
  end
end
