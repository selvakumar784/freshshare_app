class SessionsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user == nil
      flash.now[:error] = 'Username is not registered. Please register'
      render 'new'
    else
      if user && user.authenticate(params[:session][:password])
        sign_in user
        redirect_to root_path
      else
        flash.now[:error] = 'Invalid email/password combination'
        render 'new'
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
