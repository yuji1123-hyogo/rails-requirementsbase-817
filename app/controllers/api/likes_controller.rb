class Api::LikesController < ApplicationController
  before_action :authenticate_user
  def index
    @current_user.favorite_books
  end

  def create
  end

  def delete
  end
end
