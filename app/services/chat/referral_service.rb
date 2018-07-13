class Chat::ReferralService < ChatService
  def handle
    community = Community.find_by(referral_code: referral_code)

    if community &&
       (profile = user.member_profile.add_community(community)) &&
       profile.persisted?
      Responder.send_subscribed_to_community_cta(self, profile)
      return
    end

    Responder.send_get_started_cta(self, user.member_profile_communities?)
  end

  private

  def referral_code
    message.messaging.dig('referral', 'ref')
  end
end
