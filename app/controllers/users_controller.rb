class UsersController < ApplicationController
  before_action :logged_in_user, only: [:destroy, :edit, :index, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      msg = "Welcome to the Sample App! "
      msg += "Please check your email for an activation link."
      flash[:success] = msg
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def edit
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def show
    @user = User.find(params[:id])
    if !@user.activated?
      redirect_to root_url and return
    end

    @user
  end

  private

    # Confirms current user is admin
    def admin_user
      if !current_user.admin?
        redirect_to(root_url)
      end
    end

    # Confirms the correct user
    def correct_user
      user = User.find(params[:id])

      if !current_user?(user)
        redirect_to(root_url)
      end

      @user = user
    end

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
