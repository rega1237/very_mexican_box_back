class Subscription < ApplicationRecord
  attr_accessor :card_token, :change_default

  belongs_to :plan
  belongs_to :user

  validates :stripe_id, presence: true, uniqueness: true

  before_validation :create_stripe_reference, on: :create

  def create_stripe_reference
    old_card = user.cards.where(default: true)[0]

    if !card_exist?
      new_card_db = Card.new(user_id: user.id, card_token: card_token, default: change_default, from_subscription: true)
      new_card_db.save
    else
      update_existing_card(old_card)
    end

    response = Stripe::Subscription.create({
                                             customer: user.stripe_id,
                                             items: [
                                               { price: plan.stripe_id }
                                             ]
                                           })
    self.stripe_id = response.id

    if !change_default && !old_card.nil?
      user.update_default_source(old_card.stripe_id)
    end
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

  def card_exist?
    return false if user.cards.empty?

    all_cards = user.cards

    card_token_last_four = Stripe::Token.retrieve(card_token).card.last4

    all_cards.filter { |card| card.last_four == card_token_last_four }.empty? ? false : true
  end

  def update_existing_card(old_card)
    exist_card = Stripe::Token.retrieve(card_token).card.last4

    return if exist_card == old_card.last_four

    all_cards = user.cards

    matching_card = all_cards.select { |card_customer| card_customer.last_four == exist_card }
    
    user.update_default_source(matching_card[0].stripe_id)

    Card.where(user_id: user.id).update_all(default: false)
    matching_card[0].update(default: true)
    puts "UPDATE EXISTING CARD"
  end
end
