class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :spotify_id, null: false, unique: true
      t.timestamps
    end
  end
end
