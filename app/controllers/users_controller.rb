class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, except: %i[create]

  def show
    render json: @user
  end

  def user_subscriptions
    render json: @user.subscriptions
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
