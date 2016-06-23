class AddUserIdToBookrides < ActiveRecord::Migration
  def change
    add_column :bookrides, :user_id, :integer
  end
end
