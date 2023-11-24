class AddSubscriptionToCard < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :from_subscription, :boolean, default: false
  end
end
