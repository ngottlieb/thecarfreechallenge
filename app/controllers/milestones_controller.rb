class MilestonesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  def index
    @milestones = @milestones.order('threshold asc')
  end

  def create
    @milestone.created_by = current_user

    if @milestone.save
      flash[:notice] = 'Milestone created'
      redirect_to milestones_path
    else
      flash[:error] = 'There was an error creating the milestone'
      render 'new'
    end
  end

  def update
    if @milestone.update(milestone_params)
      flash[:notice] = 'Milestone updated'
      redirect_to milestones_path
    else
      flash[:error] = 'There was an error updating the milestone'
      render 'edit'
    end
  end

  def new
  end

  def edit
  end

  def destroy
    @milestone.destroy!
    flash[:notice] = 'Removed milestone'
    redirect_to milestones_path
  end

  private

  def milestone_params
    params[:milestone][:threshold].gsub!(',', '')
    params.require(:milestone).permit(:threshold, :metric, :badge, :tagline)
  end
end
