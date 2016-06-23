class StaticpagesController < ApplicationController
  def home
    if signed_in?
      @offerrides  = current_user.offerrides.where('date >= ?', Date.today).paginate(page: params[:page])
      @bookrides  = current_user.bookrides.where('date >= ?', Date.today).paginate(page: params[:page])
      flash.now[:notice] = "No Upcoming rides." if @offerrides.length == 0 and @bookrides.length == 0 
    end
  end
end
