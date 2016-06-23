class AddMoreColumns < ActiveRecord::Migration
  def up
    add_column :offerrides, :totalseats, :number
    add_column :offerrides, :seatsleft, :number
    add_column :offerrides, :contactnum, :number
  end

  def down
  end
end
