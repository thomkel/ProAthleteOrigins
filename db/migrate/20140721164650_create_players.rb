class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.string :city
      t.string :state
      t.string :country
      t.string :image_url

      t.timestamps
    end
  end
end
