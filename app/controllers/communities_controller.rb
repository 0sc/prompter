class CommunitiesController < ApplicationController
  before_action :set_graph_agent, only: [:index, :edit]
  # before_action :set_community, only: %i[edit]

  def index
    @fb_communities = @fb_graph.admin_communities
    @managed_communities =
      Community.where(fbid: @fb_graph.admin_communities_fbids).pluck(:fbid)
  end

  # def show; end

  def edit
    @fb_community = @fb_graph.community_details(params[:id])
    @community = Community.find_or_initialize_by(fbid: params[:id])
    @community.name = @fb_community['name']
    @community.save
    current_user.admin_profile.add_community(@community)

  rescue Koala::Facebook::ClientError
    redirect_to communities_path, notice: 'Community not found'
  end

  # def update
  #   if @community.update(community_params)
  #     redirect_to @community, notice: 'Community was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end
  #
  # def destroy
  #   @community.destroy
  #   redirect_to communities_url, notice: 'Community was successfully destroyed.'
  # end

  private

  def set_graph_agent
    @fb_graph = FbGraphService.new(current_user.fbid, current_user.token)
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
