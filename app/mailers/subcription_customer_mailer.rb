class SubcriptionCustomerMailer < ApplicationMailer
  def new_subscription_to_customer
    @subscription = params[:subscription]
    @customer = @subscription.user
    mail(to: @customer.email, subject: 'New subscription')
  end

  def new_subscription_to_admin
    @subscription = params[:subscription]
    @customer = @subscription.user
    mail(to: Rails.application.credentials.email, subject: 'New subscription')
  end

  def cancel_stripe_subscription_user
    @subscription = params[:subscription]
    @customer = @subscription.user
    mail(to: @customer.email, subject: 'Subscription canceled')
  end

  def cancel_stripe_subscription_admin
    @subscription = params[:subscription]
    @customer = @subscription.user
    mail(to: Rails.application.credentials.email, subject: 'Subscription canceled')
  end
end
