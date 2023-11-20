class Plan < ApplicationRecord
  validates :name, presence: true
  validates :stripe_id, presence: true, uniqueness: true

  def retrieve_stripe_reference
    Stripe::Price.retrieve(stripe_id)
  end
end
