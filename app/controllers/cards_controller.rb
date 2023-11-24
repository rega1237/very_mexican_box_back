class CardsController < ApplicationController
  before_action :set_card, only: [:show, :update, :destroy]
  before_action :set_user_cards, only: [:index]

  def index
    render json: @cards
  end

  def show
    render json: @card
  end

  def update
    if @card.update(card_params)
      render json: @card, status: :ok
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @card.destroy
      render json: { message: 'Card was successfully deleted.' }, status: :ok
    else
      render json: { message: 'Card was not deleted.' }, status: :unprocessable_entity
    end
  end
   
  def create
    @card = Card.new(card_params.merge(card_token: params[:data][:card_token]))
    if @card.save
      render json: @card, status: :created
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def set_user_cards
    @cards = Card.where(user_id: params[:user_id])
  end
  
  def card_params
    params.require(:data).permit(:user_id, :card_token, :default)
  end
end
