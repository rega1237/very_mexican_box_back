class User < ActiveRecord::Base
  before_create :create_stripe_reference

  has_many :subscriptions
  has_many :cards

  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :name, presence: true

  def create_stripe_reference
    customer = Stripe::Customer.create(email:)
    self.stripe_id = customer.id

    raise 'Error creando referencia en stripe' if stripe_id.nil?
  end

  def create_new_source(card_token)
    Stripe::Customer.create_source(
      stripe_id,
      { source: card_token }
    )
  end

  def update_default_source(card_id)
    Stripe::Customer.update(
      stripe_id,
      { default_source: card_id }
    )

    cards.update_all(default: false)
    cards.where(stripe_id: card_id)[0].update(default: true)
  end

  def retrieve_stripe_reference
    Stripe::Customer.retrieve(stripe_id)
  end
end
