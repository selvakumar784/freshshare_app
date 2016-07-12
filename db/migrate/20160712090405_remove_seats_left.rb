class RemoveSeatsLeft < ActiveRecord::Migration
  def up
    remove_column :offerrides, :seatsleft
  end

  def down
  end
end
