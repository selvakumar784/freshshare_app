class RemoveRememberDigest < ActiveRecord::Migration
  def up
    remove_column :users, :remember_digest
  end

  def down
  end
end
