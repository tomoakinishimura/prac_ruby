class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destory
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def new 
    @user = User.new
  end
  
  def show 
    @id = params[:id]
    @user = User.find(@id)
  end
  
  def create 
    @user = User.new(user_params)
    
    if @user.save
      #保存の成功をここで扱う
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
    
  end
  
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated, true)
      user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "Account actiated!!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
  
  def update 
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      #更新に成功した場合を扱う
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                  :password_confirmation)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
  
end
__END__