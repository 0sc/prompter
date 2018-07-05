module Chat::QuickReply
  FIND_COMMUNITIES = 'find-communities'.freeze
  SUBSCRIBE_COMMUNITIES = 'subscribe-communities'.freeze
  MANAGE_COMMUNITIES = 'manage-communities'.freeze

  def handle_quick_reply
    case quick_reply_payload
    when FIND_COMMUNITIES
      handle_find_community
    when SUBSCRIBE_COMMUNITIES
      handle_subscribe_communities
    when MANAGE_COMMUNITIES
      handle_manage_communities
    else
      handle_msg_reply
    end
  end

  private

  def handle_find_community
    return Responder.send_link_account_cta(self) unless user.account_linked?
    return Responder.send_renew_token_cta(self) if user.token_expired?

    service = FacebookService.new(user.fbid, user.token)
    communities = service.communities
    ids = communities.map { |community| community['id'] }
    member_communities_id = user.member_communities.map(&:id)

    # TODO: limit number of communities fetched?
    subscribable_communities =
      Community.where(fbid: ids).where.not(id: member_communities_id)

    if subscribable_communities.empty?
      # no available communities to subscribe
      @cta_options = [SUBSCRIBE_COMMUNITIES]
      @cta_options << MANAGE_COMMUNITIES if user.subscriptions?
      Responder.send_no_community_to_subscribe_cta(self)
      return
    end

    strategise_response(subscribable_communities)
  end

  def strategise_response(communities)
    communities.each_slice(4) do |grp|
      if grp.size == 1
        payload = list_template_payload_for(grp.first)
        Responder.send_single_community_to_subscribe_cta(self, payload)
      else
        payload = grp.map { |c| list_template_payload_for(c) }
        Responder.send_communities_to_subscribe_cta(self, payload)
      end
    end
  end

  def handle_subscribe_communities
    return Responder.send_link_account_cta(self) unless user.account_linked?
    return Responder.send_renew_token_cta(self) if user.token_expired?

    # opens a webview for them to use the webapp
    Responder.send_subscribe_communities_cta(self)
  end

  def handle_manage_communities
    return Responder.send_no_subscription_cta unless user.subscriptions?

    # lists users subscribed community with option
  end

  def list_template_payload_for(community)
    postback = Chat::PostbackService
               .build_subscribe_to_community_postback(community.id)
    {
      title: community.name,
      image: community.cover,
      postback: postback
    }
  end

  def quick_reply_payload
    message.messaging.dig('message', 'quick_reply', 'payload')
  end
end
