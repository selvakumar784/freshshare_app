class GetridesController < ApplicationController
  before_filter :signed_in_user, only: [:index, :new]
  def new
  end

  def index
    if params[:getrides][:source] != nil and params[:getrides][:destination] != nil
      @offerrides = Offerride.where('date >= ?', Date.today).where(:source=>params[:getrides][:source].downcase).where(:destination=>params[:getrides][:destination].downcase).paginate(page: params[:page])
    else
      @matchrider = User.find_by_name(params[:getrides][:name])
      @offerrides = @matchrider ? @matchrider.offerrides.where('date >= ?', Date.today) : []
      binding.pry
    end
    if @offerrides.length == 0
      flash.now[:sucess] = "Couldn't find a match. Please try different search criteria" 
    else
      flash.now[:sucess] = "#{@offerrides.length} Matching results" 
    end
  end
end
