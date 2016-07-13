class OfferridesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :find_ride, only: [:edit, :show, :update, :destroy]

  def new
    @offerride = Offerride.new
  end

  def create
    @offerride = current_user.offerrides.build(params[:offerride])
    @offerride.assign_params_from_controller(params[:offerride], current_user.id)
    if @offerride.save
      redirect_to @offerride
      flash.now[:success] = "You offered a ride."
    else
      render 'new'
    end
  end

  def show
  end

  def index
    @offerrides = current_user.offerrides.paginate(page: params[:page])
    @search_flag = 0
    flash.now[:notice] = "You haven't offered a ride" if @offerrides.length == 0 
  end

  def edit
  end

  def update
    new_total_seats = params[:offerride][:totalseats].to_i
    already_booked = @offerride.bookrides.sum(:numseats)
    @offerride.assign_params_from_controller(@offerride, @offerride.user_id)
    @offerride.seats_modify(new_total_seats, already_booked)

    if @offerride.update_attributes(:totalseats => new_total_seats)
      flash.now[:success] = "Ride details updated"
      redirect_to @offerride
    else
      render 'edit'
    end
  end

  def search
    @search_flag = 1
    if params[:offerrides] != nil
      if params[:offerrides][:source] != "" &&
         params[:offerrides][:destination] != ""
        @offerrides = Offerride.find_by_journey(Date.today,
                      params[:offerrides][:source].downcase, 
                      params[:offerrides][:destination].downcase).
                      paginate(page: params[:page])
        if @offerrides.length == 0
          flash.now[:success] = "Couldn't find a match. 
                               Please try different search criteria" 
          return
        end
      else
        @matchrider = User.find_by_name(params[:offerrides][:name])
        if @matchrider != nil
          @offerrides = Offerride.find_by_rider(Date.today, @matchrider.id)
        else
          flash.now[:success] = "Couldn't find a match. 
                               Please try different search criteria" 
          return
        end
      end
      flash.now[:success] = "#{@offerrides.length} Matching results" 
      render "index"
    end
  end

  def destroy
    if @offerride.present?
      if @offerride.bookrides.sum(:numseats) != 0 && 
                                 @offerride.date.to_date > Date.today
        flash[:error] = "This ride cannot be closed now. 
                        There are bookings on this."
      else
        @offerride.destroy
      end
    end
    redirect_to offerrides_path
  end

  protected
    def find_ride
      @offerride = Offerride.find(params[:id])
    end
end
