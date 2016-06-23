class Bookride < ActiveRecord::Base
  attr_accessible :date, :destination, :numseats, :source, :time, :totalcost
  attr_accessor :numseatstocancel

  belongs_to :user
  belongs_to :offerride
end
