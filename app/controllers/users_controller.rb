class UsersController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update user_params
      flash[:notice] = 'Account updated'
    end
    render 'edit'
  end

  def user_params
    params.require(:user).permit(:name, :measurement_system, :email)
  end
end
