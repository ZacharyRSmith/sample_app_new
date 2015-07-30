class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if !@user
      flash.now[:danger] = "Sorry, we do not recognize that email! :_("
      return render 'new'
    end

    @user.create_password_reset_digest
    @user.send_password_reset_email
    flash[:info] = "Email sent with password reset instructions"
    redirect_to root_url
  end

  def edit
#     if !@user || @user.password_reset_digest != User.digest(params[:id])
#       flash[:danger] = "Whoops! Something went wrong!"
#       return redirect_to root_url
#     end
  end

  def new
  end

  def update
    if params[:user][:password].empty?
      flash.now[:danger] = "Password can't be empty"
      return render 'edit'
    end
    if !@user.update_attributes(user_params)
      flash.now[:danger] = "Whoops! Something went wrong! :_("
      return render 'edit'
    end

    @user.update_attributes(user_params)
    log_in @user
    flash[:success] = "Password has been reset."
    redirect_to @user
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # BEFORE FILTERS

    def get_user
      @user = User.find_by(email: params[:email].downcase)
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired. ;_;"
        redirect_to new_password_reset_url
      end
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:password_reset, params[:id]))
        redirect_to root_url
      end
    end
end
