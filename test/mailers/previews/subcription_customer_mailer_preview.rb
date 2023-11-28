# Preview all emails at http://localhost:3000/rails/mailers/subcription_customer_mailer
class SubcriptionCustomerMailerPreview < ActionMailer::Preview
  def new_subscription_to_customer_test
    subscription = Subscription.new(user_id: 2, plan_id: 1, active: true, card_token: 'tok_visa', change_default: false)
    subscription.save
    SubcriptionCustomerMailer.with(subscription: subscription).new_subscription_to_customer
  end
end
