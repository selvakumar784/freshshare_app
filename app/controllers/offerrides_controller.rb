class OfferridesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]

  def new
    @offerride = Offerride.new
  end

  def create
    binding.pry
    @offerride = current_user.offerrides.build(params[:offerride])
    if @offerride.user.offerrides.where(:date => params[:offerride][:date]).length > 0
      flash.now[:error] = "You already offered a ride on this day. Currently we allow only one offer ride per day."
      render 'new'
    elsif @offerride.user.bookrides.where(:date => params[:offerride][:date]).length > 0
      flash.now[:error] = "You already booked a ride on this day. You cannot book and ride on the same day."
      render 'new'
    else
      if @offerride.save
        redirect_to @offerride
        flash.now[:success] = "You offered a ride."
      else
        render 'new'
      end
    end
  end

  def show
    @offerride = Offerride.find(params[:id])
  end

  def index
    @offerrides = current_user.offerrides.paginate(page: params[:page])
    flash.now[:notice] = "You haven't offered a ride" if @offerrides.length == 0 
  end

  def edit
    offerride = Offerride.find(params[:id])
    booking_exists offerride.id
  end

  def update
    @offerride = Offerride.find(params[:id])
    newtotalseats = params[:offerride][:totalseats].to_i
    alreadybooked = @offerride.bookrides.sum(:numseats)
    @bookrides = Bookride.find_by_offerride_id(params[:id])
    if @bookrides != nil
      if newtotalseats < alreadybooked
        flash.now[:error] = "Seats cannnot be reduced to this number"
        render 'edit'
      else
        updatedseats = newtotalseats - alreadybooked
        @offerride.update_attributes(:totalseats => newtotalseats)
        @offerride.update_attributes(:seatsleft => updatedseats)
        redirect_to @offerride
        flash.now[:success] = "Ride details updated"
      end
    else
      if @offerride.user.offerrides.where(:date => params[:offerride][:date]).length > 0
        flash.now[:error] = "You already offered a ride on this day. Currently we allow only one offer ride per day"
        booking_exists @offerride.id
        render 'edit'
      else
        if !@offerride.update_attributes(params[:offerride])
          booking_exists @offerride.id
          render 'edit'
        else
          redirect_to @offerride
          flash.now[:success] = "Ride details updated"
        end
      end
    end
  end

  def details
    @matchedrides = Bookride.where(:offerride_id => params[:id]).paginate(page: params[:page])
    flash.now[:notice] = "No bookings done yet." if @matchedrides.length == 0
  end

  def destroy
    @offerride = Offerride.find(params[:id])
    if @offerride.present?
      if @offerride.seatsleft != @offerride.totalseats and @offerride.date.to_date > Date.today
        flash[:error] = "This ride cannot be closed now. There are bookings on this."
      else
        @offerride.destroy
      end
    end
    redirect_to offerrides_path
  end
end
