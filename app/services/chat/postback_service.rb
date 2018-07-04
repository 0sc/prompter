class Chat::PostbackService < ChatService
  SUBSCRIBE_TO_COMMUNITY = 'subscribe-to-community-'.freeze

  def self.build_subscribe_to_community_postback(comm_id)
    "#{SUBSCRIBE_TO_COMMUNITY}#{comm_id}"
  end
end
