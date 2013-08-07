class IncludeCanceledToReservations < ActiveRecord::Migration
  def up
  	add_column :reservations, :status, :string
  	remove_column :reservations, :conflict_id
  end

  def down
  	remove_column :reservations, :canceled
  	add_column :reservations, :conflict_id, :integer
  end
end
