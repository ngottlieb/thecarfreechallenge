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

  # for facebook sharing
  def share_milestone
    @user = User.find(params[:id])
    @milestone = Milestone.find(params[:id])
    render 'share_milestone', layout: nil
  end

  def unsubscribe
    @user = User.find(params[:id])
    @user.update opt_out_of_milestone_notifications: true
    render 'unsubscribe', layout: nil
  end

  def user_params
    params.require(:user).permit(
      :name,
      :measurement_system,
      :email,
      :avatar,
      :short_bio,
      :location,
      :gender,
      :age,
      :opt_out_of_leaderboard,
      :opt_out_of_barueat_emails,
      :opt_out_of_milestone_notifications
    )
  end
end
