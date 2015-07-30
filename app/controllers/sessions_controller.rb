class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if !user
      flash.now[:danger] = "Sorry, we don't recognize that email!"
      return render 'new'
    end

    if user.authenticate(params[:session][:password])
      if !user.activated?
        msg = "You must activate your account before signing in. "
        msg += "Please check your email and spam for an activation link sent "
        msg += "when you signed up. Thanks!"
        flash[:warning] = msg

        return redirect_to root_url
      end

      log_in user

      if params[:session][:remember_me] == '1'
        remember(user)
      else
        forget(user)
      end

      redirect_back_or user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def new
  end
end
