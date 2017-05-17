class UsersController < ApplicationController
  def new
  end
  
  def show 
    @id = params[:id]
    @user = User.find(@id)
  end
  
end
