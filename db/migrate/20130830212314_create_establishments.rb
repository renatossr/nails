class CreateEstablishments < ActiveRecord::Migration
  def change
    create_table :establishments do |t|
      t.string :name
      t.string :address
      t.string :address_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :lat
      t.string :long
      t.string :phone

      t.timestamps
    end
  end
end
