class ChatService
  FIND_COMMUNITIES = 'find-communities'.freeze
  SUBSCRIBE_COMMUNITIES = 'subscribe-communities'.freeze
  MANAGE_COMMUNITIES = 'manage-communities'.freeze

  # TODO: fix the indirection
  FINETUNE_PROMPTS = MANAGE_COMMUNITIES
  ADD_COMMUNITIES = SUBSCRIBE_COMMUNITIES

  attr_reader :user, :message

  def initialize(message)
    @message = message

    @user = User.find_or_initialize_by(psid: sender_id)
    # TODO: should the user details be always updated?
    user.update_from_psid! if user.new_record?
  end

  def handle(payload)
    case payload
    when FIND_COMMUNITIES
      handle_find_community
    when SUBSCRIBE_COMMUNITIES
      handle_subscribe_communities
    when MANAGE_COMMUNITIES
      handle_manage_communities
    end
  end

  def sender_id
    message.sender['id']
  end

  def username
    user.first_name
  end

  def cta_options
    @cta_options ||= default_cta_options
  end

  private

  def default_cta_options
    options = [FIND_COMMUNITIES, SUBSCRIBE_COMMUNITIES]
    user.member_profile_communities? ? options << MANAGE_COMMUNITIES : options
  end

  def handle_find_community
    return Responder.send_link_account_cta(self) unless user.account_linked?
    return Responder.send_renew_token_cta(self) if user.token_expired?

    service = FacebookService.new(user.fbid, user.token)
    communities = service.communities
    ids = communities.map { |community| community['id'] }
    member_communities_id = user.member_profile_communities.map(&:id)

    # TODO: limit number of communities fetched?
    subscribable_communities = Community.subscribable
                                        .where(fbid: ids)
                                        .where.not(id: member_communities_id)
                                        .order(:id)

    if subscribable_communities.empty?
      # no available communities to subscribe
      @cta_options = [SUBSCRIBE_COMMUNITIES]
      @cta_options << MANAGE_COMMUNITIES if user.member_profile_communities?
      Responder.send_no_community_to_subscribe_cta(self)
      return
    end

    strategise_list_template_response(subscribable_communities)
  end

  def strategise_list_template_response(communities)
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
    subscriptions = user.member_profile_communities?
    return Responder.send_no_subscription_cta(self) unless subscriptions

    # lists users subscribed community with option
    user.member_profile.community_member_profiles.each_slice(10) do |grp|
      payload = grp.map {|c| generic_template_payload_for(c) }
      Responder.send_communities_to_manage_cta(self, payload)
    end
  end

  def list_template_payload_for(community)
    postback = Chat::PostbackService
               .build_subscribe_to_community_postback(community.id)
    {
      title: community.name,
      subtitle: "#{community.feed_categories.count} categories",
      image: community.cover,
      postback: postback
    }
  end

  def generic_template_payload_for(profile)
    {
      title: profile.community_name,
      image: profile.community.cover,
      subtitle: profile.subscribed_feed_category_summary,
      url: "/community_member_profiles/#{profile.id}/edit"
    }
  end
end
