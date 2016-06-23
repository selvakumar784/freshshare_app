module OfferridesHelper

  def booking_exists(offerride_id)
    @bookrides = Bookride.find_by_offerride_id(offerride_id)
    self.booking_flag = @bookrides.nil?
  end

  def booking_flag=(value)
    @booking_flag = value
  end


  def already_booked_seat(offerride, current_user)
    offerride.bookrides.find_by_user_id(current_user.id)
  end

  def current_user_book_id(offerride)
    offerride.bookrides.find_by_user_id(current_user.id).id
  end
end
