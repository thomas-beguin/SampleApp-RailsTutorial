class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user&.authenticate(params[:session][:password]) #authenticate method
                                                          #from has_secure_password from user.rb
      if @user.activated?
        # The session[:forwarding_url] is already saved with the logged_in_user
        # function in the use_controller file, only if it is a get request
        forwarding_url = session[:forwarding_url] # Stores the forwarding url
        reset_session # Automatically removes the forwarding URL from the session
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        log_in @user #add a session => kind of a cookie
        redirect_to forwarding_url || @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
