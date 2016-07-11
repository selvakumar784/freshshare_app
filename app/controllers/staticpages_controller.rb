class StaticpagesController < ApplicationController
  def home
    if signed_in?
      @offerrides  = Offerride.list_rides(current_user).paginate(page: params[:page])
      @bookrides  = Bookride.list_rides(current_user).paginate(page: params[:page])
      flash.now[:notice] = "No Upcoming rides." if @offerrides.length == 0 &&
                                                   @bookrides.length == 0 
    end
  end
end
