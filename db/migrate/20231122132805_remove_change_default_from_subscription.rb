class RemoveChangeDefaultFromSubscription < ActiveRecord::Migration[7.0]
  def change
    remove_column :subscriptions, :change_default
  end
end
