class UsersController < ApplicationController
  before_action :set_user, except: %i[create]

  def show
    render json: @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end