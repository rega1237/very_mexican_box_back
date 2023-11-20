class Subscription < ApplicationRecord
  attr_accessor :card_token

  belongs_to :plan
  belongs_to :user

  validates :stripe_id, presence: true, uniqueness: true

  before_validation :create_stripe_reference, on: :create

  def create_stripe_reference
    customer = user.retrieve_stripe_reference
    card_exist = card_exist?(card_token, customer)
    old_card = customer.default_source

    if !card_exist
      new_card = user.create_new_source(card_token)
      user.update_default_source(new_card.id)
    elsif card_exist && change_default
      update_existing_card(card_token, customer)
    end

    response = Stripe::Subscription.create({
                                             customer: customer.id,
                                             items: [
                                               { price: plan.stripe_id }
                                             ]
                                           })
    self.stripe_id = response.id

    return if change_default

    user.update_default_source(old_card)
  end

  def cancel_stripe_subscription(comment)
    Stripe::Subscription.cancel(
      stripe_id,
      cancellation_details: {
        comment:
      }
    )
  end

  def subscription_inactive?
    !active
  end

  private

  def card_exist?(card_token, customer)
    return false if customer.default_source.nil?

    all_cards = Stripe::Customer.list_sources(
      customer.id,
      { object: 'card' }
    )

    card_token_fingerprint = Stripe::Token.retrieve(card_token).card.fingerprint

    all_cards.each do |card_customer|
      return true if card_customer.fingerprint == card_token_fingerprint
    end

    false
  end

  def update_existing_card(card_token, customer)
    exist_card = Stripe::Token.retrieve(card_token).card.fingerprint

    all_cards = Stripe::Customer.list_sources(
      customer.id,
      { object: 'card' }
    )

    matching_card = all_cards.select { |card_customer| card_customer.fingerprint == exist_card }

    user.update_default_source(matching_card[0].id)
  end
end
