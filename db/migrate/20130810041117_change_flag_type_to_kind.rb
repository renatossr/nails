class ChangeFlagTypeToKind < ActiveRecord::Migration
  def up
    rename_column :reservations, :type_flag, :kind
  end

  def down
    rename_column :reservations, :kind, :type_flag
  end
end
