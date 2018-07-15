class AnalysisWorker
  include Sidekiq::Worker

  def perform(community_fbid, feed_msg, feed_link)
    return unless feed_link.present?

    community = Community.find_by(fbid: community_fbid)
    return unless community
    category = wit_recommended_category(feed_msg)

    each_interested_community_members(community.id, category) do |user|
      Notifier.send_community_feed_notice(
        psid: user.psid,
        name: community.name,
        category: category,
        feed: feed_msg,
        link: feed_link
      )
    end
  end

  private

  def wit_recommended_category(feed_msg)
    svc = WitService.new(feed_msg)
    svc.analyse
    svc.intent_value
  end

  def each_interested_community_members(community_id, category_name, &blk)
    raise 'I need a block' unless block_given?

    User
      .includes(member_profile: { community_member_profiles: :feed_categories })
      .where.not(users: { psid: nil })
      .where(community_member_profiles: { community_id: community_id })
      .where(feed_categories: { name: category_name }).each(&blk)
  end
end
