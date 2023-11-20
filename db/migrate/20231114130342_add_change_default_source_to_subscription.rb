class AddChangeDefaultSourceToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :change_default, :boolean, default: false
  end
end
