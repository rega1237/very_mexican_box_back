class AddShippingInfoToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :shipping_city, :string
    add_column :subscriptions, :shipping_line1, :string
    add_column :subscriptions, :shipping_line2, :string, default: ''
    add_column :subscriptions, :shipping_postal_code, :string
    add_column :subscriptions, :shipping_state, :string
    add_column :subscriptions, :shipping_name, :string
  end
end
