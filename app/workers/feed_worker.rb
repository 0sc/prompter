class FeedWorker
  include Sidekiq::Worker

  def perform
    each_eligible_community do |attr|
      # attr[user_fbid, user_token, community_fbid]
      svc = FacebookService.new(attr[0], attr[1])
      svc.community_feeds(attr[2], since: 3.hours.ago.to_i).each do |feed|
        # don't include feeds that already have folks commenting on it
        next if svc.community_feed_comments_count(feed['id']) > 2
        analyse_feed(attr[2], feed)
      end
    end
  end

  private

  def each_eligible_community(&blk)
    raise 'I need a block' unless block_given?
    token_ttl = 30.minutes.from_now.to_i # add 1 hour buffer

    Community
      .subscribable
      .includes(admin_profiles: :user)
      .where('users.expires_at > ?', token_ttl)
      .distinct('communities.fbid')
      .pluck('users.fbid, users.token, communities.fbid')
      .uniq { |community| community[2] }.each(&blk) # TODO: consider using sql
  end

  def analyse_feed(community_fbid, feed)
    AnalysisWorker.perform_async(community_fbid, feed['message'], feed['link'])
  end
end
