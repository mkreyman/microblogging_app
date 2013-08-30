class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :signed_in_but_trying_to_sign_up_again, only: [:new, :create]  # 9.6 Exercises, ex.6

  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
 	  @user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      sign_in @user
  		flash[:success] = "Welcome to the Sample App!"
  		redirect_to @user
  	else
  		render 'new'
  	end
  end

  def destroy
    if User.find(params[:id]).admin && current_user.admin
      flash[:error] = "Cannot delete current admin"
      redirect_to users_url
    else
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_to users_url
    end
  end

# "Old" destroy action
=begin
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end
=end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
  	params.require(:user).permit(:name, :email, :password, 
  		                         :password_confirmation, :admin)
  end

  # Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def signed_in_but_trying_to_sign_up_again
    redirect_to root_url if signed_in?
  end

end
