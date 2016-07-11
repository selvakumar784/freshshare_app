class Bookride < ActiveRecord::Base
  attr_accessible :date, :destination, :numseats, :source, :time, :totalcost
  attr_accessor :numseatstocancel, :cancel_or_book_flag

  belongs_to :user
  belongs_to :offerride

  before_create :time_passed
  before_save :validate_seats
  before_create :offer_exists_on_date
  before_create :book_exists_on_date

  validate :seats_check

  after_create :decrease_seats_left
  # after_destroy :increase_seats_left
  after_update :modify_seats_left

  scope :list_rides, -> (current_user) {
    where(user_id: current_user.id).where('date >= ?', Date.today)
  }

  scope :list_bookings, -> (offerride_id) {
    where(offerride_id: offerride_id)
  }

  scope :entry_exists, -> (date, user_id) {
    where(user_id: user_id).where(date: date)
  }

  def assign_params_from_controller(params, offerride)
    @book_ride_params = params
    @offerride = offerride
  end

  def offer_exists_on_date
    if Offerride.entry_exists(@book_ride_params[:date],
                              @book_ride_params[:user_id]).length > 0
      errors.add(:date, "You already offered a ride on this day. Currently we 
                         allow only one offer ride per day.")
    end
  end

  def book_exists_on_date
    if Bookride.entry_exists(@book_ride_params[:date],
                             @book_ride_params[:user_id]).length > 0
      errors.add(:date, "You already booked a ride on this day. Currently we 
                         allow only one booking ride per day.")
    end
  end

  def time_passed
    if @book_ride_params[:date] == Date.today and (@book_ride_params[:date] + 
      " " + @book_ride_params[:time] > (Time.now - 2.hours))
      errors.add(:base, "Time has already passed to book a seat for this ride.")
    end
  end

  def validate_seats
    if @book_ride_params[:numseats].to_i > @offerride[:seatsleft].to_i
      errors.add(:numseats, "Requested seats cannnot be booked")
    end
  end

  def seats_check
    if @book_ride_params[:numseatstocancel].to_i < 0
      errors.add(:base, "seats to cancel cannot be negative")
    elsif @book_ride_params[:numseatstocancel].to_i > 
          @book_ride_params[:numseats].to_i
      errors.add(:base, "you can not cancel seats more than you booked")
    end
  end

  protected
    def decrease_seats_left
      binding.pry
      @offerride.update_attribute(:seatsleft, @offerride.rem_seats)
    end

    def increase_seats_left
      binding.pry
      @offerride.update_attribute(:seatsleft, @offerride.rem_seats)
    end

    def modify_seats_left
      binding.pry
      @offerride.update_attributes(seatsleft: @offerride.rem_seats)
    end

end