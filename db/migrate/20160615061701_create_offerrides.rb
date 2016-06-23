class CreateOfferrides < ActiveRecord::Migration
  def change
    create_table :offerrides do |t|
      t.string :source
      t.string :destination
      t.string :date
      t.string :time
      t.float :cost

      t.timestamps
    end
  end
end
