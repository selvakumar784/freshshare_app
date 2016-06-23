class BookridesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy, :new, :edit, :update]

  def new
    @source = params[:source]
    @dest = params[:destination]
    @date = params[:date]
    @time = params[:time]
    @seatsleft = params[:seatsleft]
    @offerrideid = params[:offerrideid]
    @bookride = Bookride.new
  end

  def create
    params_filter = params[:bookride].except(:seatsleft)
    if params_filter[:date] == Date.today and (params_filter[:date] + " " + params_filter[:time] > (Time.now - 2.hours))
      flash[:error] = "Time has already passed to book a seat for this ride."
      redirect_to bookrides_path(params[:bookride])
      return
    end
    numseats = params_filter[:numseats].to_i
    @currentride = Offerride.find_by_id(params[:offerrideid])
    seatsleft = (@currentride.seatsleft).to_i
    if validate_seats numseats, seatsleft
      @bookride = current_user.bookrides.build(params_filter)
      if @bookride.user.bookrides.where(:date => params_filter[:date]).length > 0
        flash.now[:error] = "You already booked a ride for this day. Currently we allow only book per day"
        redirect_to new_bookride_path(params[:bookride])
      elsif @bookride.user.offerrides.where(:date => params_filter[:date]).length > 0
        flash[:error] = "You already offered a ride on this day. You cannot book and ride on the same day."
        redirect_to bookrides_path
      else
        @bookride.offerride_id = @currentride.id
        @bookride.totalcost = numseats.to_i * @currentride.cost
        if @bookride.save
          flash[:success] = "Successfully Booked"
          remseats = @currentride.seatsleft - numseats.to_i
          #@currentride.update_attribute(:seatsleft, remseats)
          redirect_to @bookride
        else
          redirect_to new_bookride_path(params[:bookride])
        end
      end
    else
      flash[:failure] = "Requested seats cannot be booked"
      redirect_to new_bookride_path(params[:bookride])
    end
  end

  def bookmore
    @seatsleft = params[:seatsleft]
    @bookride = Bookride.find_by_id(params[:id])
  end

  def bookmoreupdate
    numseats = params[:bookride][:numseats].to_i
    @bookride = Bookride.find_by_id(params[:id])
    @currentride = @bookride.offerride
    seatsleft = params[:seatsleft].to_i
    if validate_seats numseats, seatsleft
      prevcost = @bookride.totalcost
      prevseats = @bookride.numseats
      newtotalcost = prevcost + (numseats * @currentride.cost)
      newnumseats = prevseats + numseats
      @bookride.update_attribute(:numseats, newnumseats)
      @bookride.update_attribute(:totalcost, newtotalcost)
      if @bookride.save
        flash[:success] = "Successfully Booked"
        remseats = @currentride.seatsleft - numseats
        @currentride.update_attribute(:seatsleft, remseats)
        redirect_to @bookride
      else
        redirect_to new_bookride_path(params[:bookride])
      end
    else
      flash[:failure] = "Requested seats cannot be booked"
      redirect_to new_bookride_path(params[:bookride])
    end
  end

  def index
    @bookrides = current_user.bookrides.paginate(page: params[:page])
    flash.now[:notice] = "No bookings found" if @bookrides.length == 0 
  end

  def show
    @bookride = Bookride.find(params[:id])
  end

  def destroy
    @bookride = Bookride.find(params[:id])
    if @bookride.present?
      @currentride = Offerride.find_by_id(@bookride.offerride_id)
      seatsleft = @currentride.seatsleft.to_i
      numseats = @bookride.numseats.to_i
      newseats = seatsleft + numseats
      @currentride.update_attributes(:seatsleft => newseats)
      @bookride.destroy
    end
    redirect_to bookrides_path
  end

  def cancel
    @bookride = Bookride.find(params[:id])
  end

  def update
    @currentride = Bookride.find_by_id(params[:id])
    @offerride = Offerride.find_by_id(@currentride.offerride_id)
    seatsbooked = @currentride.numseats.to_i
    seatscanceled = params[:bookride][:numseatstocancel].to_i

    if seatscanceled < 0
      flash[:error] = "seats to cancel cannot be negative"
      redirect_to bookrides_path
    elsif seatscanceled > seatsbooked
      flash[:error] = "you can not cancel seats more than you booked"
      redirect_to bookrides_path
    elsif seatscanceled == seatsbooked
      destroy
    else
      updatedseats = seatsbooked - seatscanceled
      seatsleft =  @offerride.seatsleft + seatscanceled
      seatscost = @currentride.totalcost.to_f
      refund = seatscanceled * @currentride.offerride.cost
      updatedcost = seatscost - refund
      @currentride.update_attributes(:numseats => updatedseats)
      @currentride.update_attributes(:totalcost => updatedcost)
      @offerride.update_attributes(:seatsleft => seatsleft)
      redirect_to bookrides_path
    end
  end
end

private
  def validate_seats numseats, seatsleft
    return numseats > seatsleft ? false : true
  end
