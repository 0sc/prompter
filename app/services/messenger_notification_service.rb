class MessengerNotificationService
  ME_LINK = ENV.fetch('BOT_URL')

  def self.build_referral_link(code)
    ME_LINK + '?ref=' + code
  end

  ## Community actions
  def self.send_community_added(user_id, community_id)
    user = User.find_by(id: user_id)
    return unless user.present? && user.psid.present?

    community = user.admin_profile_communities.find_by(id: community_id)
    return unless community.present?

    Notifier.send_community_added_notice(
      psid: user.psid,
      name: community.name,
      link: build_referral_link(community.referral_code)
    )
  end

  def self.send_community_type_changed(community_id)
    community = Community.find_by(id: community_id)
    return unless community.present?

    community.community_member_profiles.each do |profile|
      Notifier.send_community_type_changed_notice(
        psid: profile.member_profile.user.psid,
        pid: profile.id,
        name: community.name,
        type: community.community_type_name,
        info: profile.subscribed_feed_category_summary
      )
    end
  end

  def self.send_community_removed(community_id)
    community = Community.find_by(id: community_id)
    return unless community.present?

    community.member_profiles.each do |profile|
      Notifier.send_community_removed_notice(
        psid: profile.user.psid,
        name: community.name
      )
    end
  end

  ## Community Profile

  def self.send_community_profile_deleted(user_id, community_id)
    user = User.find_by(id: user_id)
    return unless user.present? && user.psid.present?

    community = Community.find_by(id: community_id)
    return unless community.present?

    Notifier.send_community_profile_deleted_notice(
      psid: user.psid,
      name: community.name
    )
  end

  def self.send_community_profile_updated(profile_id)
    profile = CommunityMemberProfile.find_by(id: profile_id)
    return unless profile.present?

    Notifier.send_community_profile_updated_notice(
      psid: profile.member_profile.user.psid,
      info: profile.subscribed_feed_category_summary,
      name: profile.community_name
    )
  end

  ## Tokens

  def self.send_access_token_expired(user_id)
    user = User.find_by(id: user_id)
    return unless user.present? && user.psid.present?

    Notifier.send_access_token_expired_notice(
      psid: user.psid,
      num_admin_comms: user.admin_profile_community_count
    )
  end

  def self.send_access_token_expiring(user_id)
    user = User.find_by(id: user_id)
    return unless user.present? && user.psid.present?

    Notifier.send_access_token_expiring_notice(
      psid: user.psid,
      num_admin_comms: user.admin_profile_community_count
    )
  end
end
