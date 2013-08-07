class ChangeDataTypesInReservation < ActiveRecord::Migration
  def up
		change_column :reservations, :start_time, :datetime
		change_column :reservations, :end_time, :datetime
		remove_column :reservations, :date
		rename_column :reservations, :type, :type_flag
  end

  def down
  	change_column :reservations, :start_time, :time
		change_column :reservations, :end_time, :time
		add_column 		:reservations, :date, :date
		rename_column :reservations, :type_flag, :type
  end
end
