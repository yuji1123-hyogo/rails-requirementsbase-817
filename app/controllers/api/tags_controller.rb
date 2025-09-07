class Api::TagsController < ApplicationController
  before_action :set_tags, only: [:show ]
  before_action :authenticate_user


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

  def set_tags
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('タグが見つかりません', {}, :not_found)
  end
end
