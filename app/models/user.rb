# frozen_string_literal: true

class User < ActiveRecord::Base
  before_validation :create_stripe_reference, on: :create

  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :stripe_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true

  def create_stripe_reference
    customer = Stripe::Customer.create(email: email)
    self.stripe_id = customer.id
  end

  def retrieve_stripe_reference
    Stripe::Customer.retrieve(stripe_id)
  end
end
