class CardsController < ApplicationController
  def create
    @card = Card.new(card_params.merge(card_token: params[:data][:card_token]))
    if @card.save
      render json: @card, status: :created
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  private

  def card_params
    params.require(:data).permit(:user_id, :card_token, :default)
  end
end
