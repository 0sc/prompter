class Chat::PostbackService < ChatService
  SUBSCRIBE_TO_COMMUNITY = 'subscribe-to-community'.freeze

  def handle
    action, param = parse_postback(payload)
    case action
    when SUBSCRIBE_TO_COMMUNITY
      handle_subscribe_to_community(param)
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

    user.member_profile.add_community(community)
    Responder.send_subscribed_to_community_cta(self, community)
  end
end
