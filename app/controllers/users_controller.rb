class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update,:destroy,
                                        :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def new
    @user = User.new
  end
  def index
    @users = User.paginate(page: params[:page])
  end
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your Email for account activation"
      redirect_to root_url
    else
      flash[:danger] = "Something went wrong"
      render 'new'
    end
  end

  def edit
    @user = User.find( params[:id] )
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User was deleted"
    redirect_to users_url
  end

  def followers
    @title = "followers"
    @user = User.find(params[:id])
    @followers = @user.passive_relationships.paginate(page: params[:page])
  end

  def following
    @user = User.find(params[:id])
    @title = "Followings for #{@user.name}"
    @followers = @user.active_relationships.paginate(page: params[:page])
  end
private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end  
# moved logged_in_user method to application controller

  def correct_user
    @user = User.find(params[:id])
    redirect_to(login_url) unless current_user?(@user)
  end
    
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

end
