class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :type
      t.text :description

      t.timestamps
    end
  end
end
