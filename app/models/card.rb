class Card < ApplicationRecord
  attr_accessor :card_token

  belongs_to :user

  validates :stripe_id, presence: true, uniqueness: true
  validates :last_four, presence: true, uniqueness: true 

  before_validation :create_stripe_card_reference, on: :create
  before_destroy :delete_stripe_card_reference
  before_update :update_stripe_card_reference

  def create_stripe_card_reference
    oldcard = user.cards.where(default: true)

    if from_subscription
        response = user.create_new_source(card_token)
  
        set_values(response, oldcard)
        
        update_default_source(response.id)
        update_default_db if default
    elsif !card_exist?
      response = user.create_new_source(card_token)

      set_values(response, oldcard)

      if default
        update_default_db
        update_default_source(response.id)
      elsif !oldcard.empty? && !default
        update_default_source(oldcard[0].stripe_id)
      end
    end
  end

  private

  def set_values(response, oldcard)
    self.stripe_id = response.id
    self.last_four = response.last4
    self.brand = response.brand
    self.exp_month = response.exp_month
    self.exp_year = response.exp_year
    self.name_on_card = response.name
    if oldcard.empty?
      self.default = true
    else
      self.default = default
    end
  end

  def card_exist?
    return false if user.cards.empty?

    all_cards = user.cards

    card_token_last_four = Stripe::Token.retrieve(card_token).card.last4

    all_cards.filter { |card| card.last_four == card_token_last_four }.empty? ? false : true
  end

  def update_default_source(card_id)
    Stripe::Customer.update(
      user.stripe_id,
      { default_source: card_id }
    )
  end

  def update_default_db
    all_cards = user.cards

    all_cards.update_all(default: false)

    self.default = true
  end

  def update_stripe_card_reference
    if default
      update_default_source(stripe_id)
      update_default_db
    end
  end

  def delete_stripe_card_reference
    Stripe::Customer.delete_source(
      user.stripe_id,
      stripe_id
    )
  end
end
