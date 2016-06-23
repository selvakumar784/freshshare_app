class CreateBookrides < ActiveRecord::Migration
  def change
    create_table :bookrides do |t|
      t.string :source
      t.string :destination
      t.string :date
      t.string :time
      t.integer :numseats
      t.float :totalcost

      t.timestamps
    end
  end
end
