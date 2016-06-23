class AddUserReferenceToOfferride < ActiveRecord::Migration
  def change
    add_column :offerrides, :user_id, :integer
  end
end
