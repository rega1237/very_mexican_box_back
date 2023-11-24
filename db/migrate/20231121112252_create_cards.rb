class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :stripe_id
      t.string :brand
      t.integer :exp_month
      t.integer :exp_year
      t.string :last_four
      t.string :name_on_card
      t.boolean :default, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
