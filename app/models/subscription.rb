class Subscription < ApplicationRecord
  attr_accessor :card_token

  belongs_to :plan
  belongs_to :user
  
  validates :stripe_id, presence: true, uniqueness: true
  
  before_validation :create_stripe_reference, on: :create
  
  def create_stripe_reference
    customer = user.retrieve_stripe_reference
    cardExist = card_exist?(card_token, customer)
    oldCard = customer.default_source

    if !cardExist
      new_card = user.create_new_source(card_token)
      user.update_default_source(new_card.id)
    elsif cardExist && change_default
      updateExistingCard(card_token, customer)
    end

    response = Stripe::Subscription.create({
      customer: customer.id,
      items: [
        { price: plan.stripe_id },
      ]
    })
    self.stripe_id = response.id

    if !change_default
      user.update_default_source(oldCard)
    end
  end
  
  def cancel_stripe_subscription(comment)
    Stripe::Subscription.cancel(
      self.stripe_id,
      cancellation_details: {
        comment: comment
      }
    )
  end
  
  def subscription_inactive?
    !active
  end
  
  private
  
  def card_exist?(card_token, customer)
    if customer.default_source == nil
      return false
    end

    all_cards = Stripe::Customer.list_sources(
      customer.id,
      {object: 'card'},
    )

    card_token_fingerprint = Stripe::Token.retrieve(card_token).card.fingerprint

    all_cards.each do |card_customer|
      if card_customer.fingerprint == card_token_fingerprint
        return true
      end
    end

    return false
  end

  def updateExistingCard(card_token, customer)
    existCard = Stripe::Token.retrieve(card_token).card.fingerprint

    all_cards = Stripe::Customer.list_sources(
      customer.id,
      {object: 'card'},
    )

    matchingCard = all_cards.select { |card_customer| card_customer.fingerprint == existCard}

    user.update_default_source(matchingCard[0].id)
  end
end
