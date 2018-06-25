class CommunitiesController < ApplicationController
  before_action :set_graph_agent, only: %i[index edit]
  before_action :set_community, only: %i[show update]

  def index
    @fb_communities = @fb.admin_communities
    # create a mapping of fbid => id
    @subscribed_communities_mapping =
      current_user.admin_communities.pluck(:fbid, :id).to_h

    # TODO: what of case of user no longer admin of a group?
    # should we update this here to remove groups
    # the user no longer have admin access to
  end

  def show; end

  def edit
    @fb_community = @fb.community_details(params[:id])
    @community = Community.find_or_initialize_by(fbid: params[:id])
    @community.name = @fb_community['name']
    @community.save
    current_user.admin_profile.add_community(@community)

  rescue Koala::Facebook::ClientError
    redirect_to communities_path, notice: 'Community not found'
  end

  def update
    redirect_to @community, notice: 'Community was successfully updated.'
    # if @community.update(community_params)
    # else
    #   render :edit
    # end
  end
  #
  # def destroy
  #   @community.destroy
  #   redirect_to communities_url, notice: 'Community was successfully destroyed.'
  # end

  private

  def set_graph_agent
    @fb = FacebookService.new(current_user.fbid, current_user.token)
  end

  def set_community
    @community = current_user.admin_profile.communities.find_by(id: params[:id])

    unless @community.present?
      redirect_to communities_path, notice: 'Community not found'
    end
  end

  # def set_community
  #   @community = Community.find_or_initialize_by(fbid: params[:id])
  #
  #   @community =
  #     current_user.admin_profile.communities.find_or_initialize_by(fbid: params[:id])
  #     binding.pry
  # end

  # def community_params
  #   params.require(:community).permit(:fbid, :name)
  # end
end
