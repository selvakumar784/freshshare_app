class BookridesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy, :new, :edit, :update]
  before_filter :find_book, only: [:edit, :show, :destroy, :cancel]

  def new
    @bookride = Bookride.new
    @offerride= Offerride.find_by_id(params[:offerride_id])
  end

  def create
    params_filter = params[:bookride].except(:seatsleft)
    @bookride = current_user.bookrides.build(params_filter)
    @offerride = Offerride.find_by_id(params[:offerride_id])
    @bookride.assign_params_from_controller(@bookride, @offerride)
    num_seats = params_filter[:numseats].to_i

    @bookride.offerride_id = @offerride.id
    @bookride.totalcost = num_seats * @offerride.cost
    if @bookride.save
      flash[:success] = "Successfully Booked"
      redirect_to @bookride
    else
      render 'new'
    end
  end

  def index
    @bookrides = current_user.bookrides.paginate(page: params[:page])
    if @bookrides.length == 0 
      flash.now[:notice] = "No bookings found"
    else
      render "index"
    end
  end

  def show
  end

  def edit
    @bookride.cancel_or_book_flag = params[:cancel_book_flag].to_i
    @offerride = Offerride.find_by_id(@bookride.offerride_id)
  end

  def destroy
    @bookride = Bookride.find(params[:id])
    if @bookride.present?
      @offerride = Offerride.find_by_id(@bookride.offerride_id)
      @offerride.assign_params_from_controller(@offerride,
                                                 @offerride.user_id)
      num_seats = @bookride.numseats.to_i
      @bookride.destroy
    end
    redirect_to bookrides_path
  end

  def cancel
  end

  def update
    cancel_or_book_flag = params[:bookride][:cancel_or_book_flag].to_i
    @bookride = Bookride.find_by_id(params[:id])
    @offerride = @bookride.offerride
    @bookride.assign_params_from_controller(params[:bookride], @offerride)
    @offerride.assign_params_from_controller(@offerride, 
                                             @offerride.user_id)

    if cancel_or_book_flag == 1
      seats_booked = @bookride.numseats.to_i
      seats_canceled = params[:bookride][:numseatstocancel].to_i

      if seats_canceled == seats_booked
        destroy
      else
        updated_seats = seats_booked - seats_canceled
        seats_cost = @bookride.totalcost.to_f
        refund = seats_canceled * @bookride.offerride.cost
        updated_cost = seats_cost - refund
        if @bookride.update_attributes(numseats: updated_seats,
                                       totalcost: updated_cost)
          redirect_to bookrides_path
        else
          @bookride[:numseats] = seats_booked
          @bookride.cancel_or_book_flag = 1
          render "edit"
        end
      end
    else
      num_seats = params[:bookride][:numseats].to_i
      prev_cost = @bookride.totalcost
      prev_seats = @bookride.numseats
      new_total_cost = prev_cost + (num_seats * @offerride.cost)
      new_num_seats = prev_seats + num_seats
      if @bookride.update_attributes(numseats: new_num_seats,
                                     totalcost: new_total_cost)
          flash[:success] = "Successfully Booked"
          redirect_to @bookride
      else
        @bookride.cancel_or_book_flag = 2
        render "edit"
      end
    end
  end

  protected
    def find_book
      if params[:flag] == "1"
        @bookride = Bookride.list_bookings(params[:id])
        @book_details = 1
        flash.now[:notice] = "No bookings done yet." if @bookride.length == 0
      else
        @bookride = Bookride.find(params[:id])
      end
    end
end

