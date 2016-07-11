module OfferridesHelper

  def already_booked_seat(offerride, current_user)
    offerride.bookrides.find_by_user_id(current_user.id)
  end

  def current_user_book_id(offerride)
    offerride.bookrides.find_by_user_id(current_user.id).id
  end
end
