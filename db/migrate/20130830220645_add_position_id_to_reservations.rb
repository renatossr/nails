class AddPositionIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :position_id, :integer
    add_index :reservations, :position_id
  end
end
