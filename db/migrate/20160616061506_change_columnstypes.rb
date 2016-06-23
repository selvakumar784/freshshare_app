class ChangeColumnstypes < ActiveRecord::Migration
  def up
    change_column :offerrides, :totalseats, :integer
    change_column :offerrides, :seatsleft, :integer
    change_column :offerrides, :contactnum, :string
  end

  def down
  end
end
