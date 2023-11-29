class Subscription < ApplicationRecord
  attr_accessor :card_token, :change_default

  belongs_to :plan
  belongs_to :user

  validates :stripe_id, presence: true, uniqueness: true
  validates :plan_id, presence: true
  validates :user_id, presence: true
  validates :card_token, presence: true, on: :create
  validates :shipping_city, presence: true, on: :create
  validates :shipping_line1, presence: true, on: :create
  validates :shipping_postal_code, presence: true, on: :create
  validates :shipping_state, presence: true, on: :create
  validates :shipping_name, presence: true, on: :create

  before_validation :create_stripe_reference, on: :create

  def create_stripe_reference
    old_card = user.cards.where(default: true)[0]

    if card_exist?
      update_existing_card(old_card)
    else
      new_card_db = Card.new(user_id: user.id, card_token:, default: change_default, from_subscription: true)
      new_card_db.save
    end

    response = Stripe::Subscription.create({
                                             customer: user.stripe_id,
                                             items: [
                                               { price: plan.stripe_id }
                                             ]
                                           })
    self.stripe_id = response.id

    return unless !change_default && !old_card.nil?

    user.update_default_source(old_card.stripe_id)
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

  def retrieve_stripe_info
    Stripe::Subscription.retrieve(stripe_id)
  end

  private

  def card_exist?
    return false if user.cards.empty?

    all_cards = user.cards

    card_token_last_four = Stripe::Token.retrieve(card_token).card.last4

    all_cards.any? { |card| card.last_four == card_token_last_four }
  end

  def update_existing_card(old_card)
    exist_card = Stripe::Token.retrieve(card_token).card.last4

    return if exist_card == old_card.last_four

    all_cards = user.cards

    matching_card = all_cards.select { |card_customer| card_customer.last_four == exist_card }

    user.update_default_source(matching_card[0].stripe_id)

    Card.where(user_id: user.id).update_all(default: false)
    matching_card[0].update(default: true)
  end
end
