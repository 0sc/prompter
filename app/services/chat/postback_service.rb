class Chat::PostbackService < ChatService
  SUBSCRIBE_TO_COMMUNITY = 'subscribe-to-community'.freeze
  GET_STARTED = 'get-started'.freeze

  def handle
    action, param = parse_postback(payload)
    case action
    when SUBSCRIBE_TO_COMMUNITY
      handle_subscribe_to_community(param)
    when GET_STARTED
      handle_get_started
    else
      super(action)
    end
  end

  def self.build_subscribe_to_community_postback(comm_id)
    "#{SUBSCRIBE_TO_COMMUNITY}_#{comm_id}"
  end

  private

  def payload
    message.messaging.dig('postback', 'payload')
  end

  def parse_postback(postback)
    postback.split('_')
  end

  def handle_subscribe_to_community(community_id)
    community = Community.find_by(id: community_id)
    return Responder.send_community_not_found_cta(self) if community.nil?

    profile = user.member_profile.add_community(community)
    Responder.send_subscribed_to_community_cta(self, profile)
  end

  def handle_get_started
    Responder.send_welcome_note(self)
    # TODO: send typing

    manage_opt = referral? ? handle_get_started_with_referral : false
    Responder.send_get_started_cta(self, manage_opt)
  end

  def handle_get_started_with_referral
    community = Community.find_by(referral_code: referral_code)
    return false unless community.present?
    # TODO: should I send special message???
    user.member_profile.add_community(community).persisted?
  end

  def referral?
    referral_code.present?
  end

  def referral_code
    message.messaging.dig('postback', 'referral', 'ref')
  end
end
