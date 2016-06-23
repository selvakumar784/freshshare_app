class AddOfferIdToBookRide < ActiveRecord::Migration
  def change
    add_column :bookrides, :offerride_id, :integer
  end
end
