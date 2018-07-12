class CommunitiesController < ApplicationController
  before_action :set_graph_agent, only: %i[index create]
  before_action :set_community, only: %i[show edit update destroy]

  def index
    @fb_communities = @fb.admin_communities
    # create a mapping of fbid => id
    @subscribed_communities_mapping =
      current_user.admin_profile_communities.pluck(:fbid, :id).to_h

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

    add_community_to_user_profiles(community)
    send_notification_of_community_addition(community)

    redirect_to edit_community_path(community)
  rescue Koala::Facebook::ClientError
    redirect_to communities_path, notice: 'Community not found'
  end

  def update
    type_changed =
      community_params[:community_type_id].to_i != @community.community_type_id

    if @community.update(community_params)
      handle_community_type_changed(@community) if type_changed

      # TODO: inform other admins of the change: field_changed
      redirect_to @community, notice: 'Community was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    remove_community_from_user_profiles(@community)
    if @community.admin_profiles.empty?
      send_notification_of_community_removal(@community)
      @community.destroy
    end

    msg = "Your '#{@community.name}' community subscription has been removed"
    redirect_to communities_url, notice: msg
  end

  private

  def add_community_to_user_profiles(community)
    current_user.admin_profile.add_community(community)
    current_user.member_profile.add_community(community)
  end

  def remove_community_from_user_profiles(community)
    current_user.admin_profile.remove_community(community)
    current_user.member_profile.remove_community(community)
  end

  def send_notification_of_community_addition(community)
    return unless current_user.psid?
    MessengerNotificationWorker
      .perform_async('send_community_added', current_user.id, community.id)
  end

  def send_notification_of_community_removal(community)
    # TODO: currently not working since community is deleted before job runs new.perform
    MessengerNotificationWorker
      .perform_async('send_community_removed', community.id)
  end

  def handle_community_type_changed(community)
    community.community_member_profiles.find_each do |profile|
      profile.unsubscribe_from_all_feed_categories # remove old ones
      profile.subscribe_to_all_feed_categories # add new ones
    end
    send_notification_of_type_change(community)
  end

  def send_notification_of_type_change(community)
    MessengerNotificationWorker
      .perform_async('send_community_type_changed', community.id)
  end

  def set_graph_agent
    @fb = FacebookService.new(current_user.fbid, current_user.token)
  end

  def set_community
    @community = current_user.admin_profile_communities.find_by(id: params[:id])

    unless @community.present?
      redirect_to communities_path, notice: 'Community not found'
    end
  end

  def community_params
    params.require(:community).permit(:community_type_id)
  end
end
