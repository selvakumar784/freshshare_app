class Offerride < ActiveRecord::Base
  attr_accessible :cost, :date, :destination, :source, :time, :user_id, 
                  :seatsleft, :totalseats, :contactnum
  attr_accessor :rem_seats
  belongs_to :user
  has_many :bookrides, dependent: :destroy

  scope :list_rides, -> (current_user) {
    where(user_id: current_user.id).where('date >= ?', Date.today)
  }
  scope :entry_exists, -> (date, user_id) {
    where(user_id: user_id).where(:date => date)
  }

  scope :find_by_journey, -> (date, source, destination) {
    where('date >= ?', Date.today).where(:source=>source.downcase).
    where(:destination=>destination.downcase)
  }

  scope :find_by_rider, -> (date, rider_id) {
    where('date >= ?', Date.today).where(:user_id => rider_id)
  }

  validates :source, :destination, :time, :date, :cost,
            :totalseats, presence: true
  validates :contactnum, presence: true, length: { minimim:10, maximum:10 }
  before_save :validate_date
  before_save :validate_time
  before_save :validate_src_dest
  before_save :downcase_fields
  validate :offer_exists_on_date 
  validate :book_exists_on_date
  validate :seats_check
  before_create :set_seats_left

  def downcase_fields
    self.source.downcase!
    self.destination.downcase!
  end

  def validate_date
    if Date.parse(date) < Date.today
      errors.add(:date, " can't be in the past")
    end
  end

  def validate_time
    if Date.parse(date) == Date.today && Time.parse(time) < Time.now
      errors.add(:time, "Time can't be in the past")
    end
  end

  def validate_src_dest
    if source == destination
      errors.add(:time, "Source and destination can't be same")
    end
  end

  def set_seats_left
    if self.totalseats <= 0
     errors.add(:seatsleft, "cannot be negative or zero")
    else
      self.seatsleft = self.totalseats
    end
  end

  def assign_params_from_controller(params, currrent_user_id)
    binding.pry
    @offer_ride_params = params
    @user_id = currrent_user_id
  end

  def seats_modify(newseats, alreadybooked)
    @newtotalseats = newseats
    @alreadybooked = alreadybooked
  end

  def offer_exists_on_date
    binding.pry
    if Offerride.entry_exists(@offer_ride_params[:date], @user_id).length > 0 &&
       @offer_ride_params[:id] == nil
      errors.add(:date, "You already offered a ride on this day. 
                        Currently we allow only one offer ride per day.")
    end
  end

  def book_exists_on_date
    if Bookride.entry_exists(@offer_ride_params[:date], 
                             @user_id).length > 0
      errors.add(:date, "You already booked a ride on this day. 
                         Currently we allow only one booking ride per day.")
    end
  end

  def seats_check
    @bookrides = Bookride.find_by_offerride_id(@offer_ride_params[:id])
    if @bookrides != nil
      if @newtotalseats.to_i < @alreadybooked.to_i
        errors.add(:seatsleft, "Seats cannnot be reduced to this number")
      end
    end
  end
end
