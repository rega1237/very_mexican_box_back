class SubscriptionsController < ApplicationController
  before_action :set_subscription, except: %i[create]
  
  def show
    render json: @subscription
  end
  
  def create
    @subscription = Subscription.new(subscription_params.merge(card_token: params[:data][:card_token]))
    if @subscription.save
      render json: @subscription, status: :created
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end
  
  def update
    if @subscription.update(subscription_params)
      if @subscription.subscription_inactive?
        @subscription.cancel_stripe_subscription(params[:data][:comment])
      end
      render json: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_subscription
    puts params[:id]
    @subscription = Subscription.find(params[:id])
  end
  
  def subscription_params
    params.require(:data).permit(:user_id, :plan_id, :active, :card_token, :change_default) 
  end
end
