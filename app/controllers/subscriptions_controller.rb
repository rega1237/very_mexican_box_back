class SubscriptionsController < ApplicationController
  before_action :set_subscription, except: %i[create]

  def show
    render json: @subscription
  end

  def create
    @subscription = Subscription.new(subscription_params.merge(card_token: params[:data][:card_token],
                                                               change_default: params[:data][:change_default]))
    if @subscription.save
      SubcriptionCustomerMailer.with(subscription: @subscription).new_subscription_to_customer.deliver_later
      SubcriptionCustomerMailer.with(subscription: @subscription).new_subscription_to_admin.deliver_later
      render json: @subscription, status: :created
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  def update
    if @subscription.update(subscription_params)
      @subscription.cancel_stripe_subscription(params[:data][:comment]) if @subscription.subscription_inactive?
      SubcriptionCustomerMailer.with(subscription: @subscription).cancel_stripe_subscription_user.deliver_later
      SubcriptionCustomerMailer.with(subscription: @subscription).cancel_stripe_subscription_admin.deliver_later
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
    params.require(:data).permit(:user_id, :plan_id, :active, :card_token, :change_default, :shipping_city,
                                 :shipping_line1, :shipping_line2, :shipping_postal_code, :shipping_state,
                                 :shipping_name)
  end
end
