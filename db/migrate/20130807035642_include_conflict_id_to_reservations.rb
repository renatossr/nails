class IncludeConflictIdToReservations < ActiveRecord::Migration
  def up
  	add_column :reservations, :conflict_id, :integer
  end

  def down
  	remove_column :reservations, :conflict_id
  end
end
