class CommunitiesController < ApplicationController
  before_action :set_graph_agent, only: %i[index create]
  before_action :set_community, only: %i[show edit update destroy]

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

  def edit; end

  def create
    graph_info = @fb.community_details(params[:fbid])
    community = Community.find_or_initialize_by(fbid: params[:fbid])
    community.update_from_fb_graph!(graph_info)
    current_user.admin_profile.add_community(community)
    current_user.member_profile.add_community(community)
    redirect_to edit_community_path(community)
# TODO: if user's psid is set inform them of addition
  rescue Koala::Facebook::ClientError
    redirect_to communities_path, notice: 'Community not found'
  end

  def update
    if @community.update(community_params)
      # TODO: 
      # if community type change update all subscribed users to all
      # send a message to them all.
      # inform other admins of the change: field_changed
      redirect_to @community, notice: 'Community was successfully updated.'
    else
      render :edit
    end


  end

  def destroy
    current_user.admin_profile.remove_community(@community)
    current_user.member_profile.remove_community(@community)
    @community.destroy if @community.admin_profiles.empty?

    msg = "Your '#{@community.name}' community subscription has been removed"
    redirect_to communities_url, notice: msg
  end

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

  def community_params
    params.require(:community).permit(:community_type_id)
  end
end
