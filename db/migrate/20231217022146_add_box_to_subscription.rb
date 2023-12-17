class AddBoxToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :box, :string
  end
end
