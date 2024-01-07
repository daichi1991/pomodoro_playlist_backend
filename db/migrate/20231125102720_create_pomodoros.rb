class CreatePomodoros < ActiveRecord::Migration[7.0]
  def change
    create_table :pomodoros, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :work_time_playlist_id, null: false
      t.string :break_time_playlist_id, null: false
      t.integer :work_time, null: false
      t.integer :break_time, null: false
      t.integer :term_count, null: false
      t.integer :long_break_time, null: false
      t.integer :term_repeat_count, null: false
      t.timestamps
    end
  end
end
