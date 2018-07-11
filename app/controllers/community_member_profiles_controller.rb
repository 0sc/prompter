class CommunityMemberProfilesController < ApplicationController
  before_action :set_community_member_profile, except: :curtain
  before_action :set_community, except: :curtain

  def show
  end

  def edit
  end

  def curtain
  end

  def update
    if empty_feed_category_subscription?
      @community_member_profile.destroy
      send_notification_of_profile_deletion

      redirect_to curtain_community_member_profiles_path
      # TODO: consider closing with redirect
      # https://developers.facebook.com/docs/messenger-platform/webview#close
    elsif @community_member_profile.update(community_member_profile_params)
      send_notification_of_profile_update(@community_member_profile)
      redirect_to @community_member_profile, notice: 'Updated successfully!'
    else
      render :edit
    end
  end

  private

  def set_community_member_profile
    @community_member_profile = current_user
                                .member_profile
                                .community_member_profiles
                                .find_by(id: params[:id])

    msg = 'Community profile not found'
    # TODO: should this redirect to curtain?
    # to reduce chance of duplicate account
    redirect_to root_path, notice: msg unless @community_member_profile
  end

  def set_community
    @community = @community_member_profile.community
  end

  def send_notification_of_profile_update(profile)
    MessengerNotificationWorker
      .perform_async('send_community_profile_updated', profile.id)
  end

  def send_notification_of_profile_deletion
    MessengerNotificationWorker.perform_async(
      'send_community_profile_deleted', current_user.id, @community.id
    )
  end

  def empty_feed_category_subscription?
    feed_category_ids = community_member_profile_params[:feed_category_ids]
    feed_category_ids.empty? || feed_category_ids == ['']
  end

  def community_member_profile_params
    params.require(:community_member_profile).permit(feed_category_ids: [])
  end
end
