class DummyFacebookService
  attr_accessor :admin_communities,
                :admin_communities_fbids,
                :communities,
                :community_feed_comments

  def initialize
    @admin_communities = []
    @communities = []
  end

  def new(fbid, token)
    @fbid = fbid
    @token = token
    self
  end

  def community_details(id)
    community = admin_communities.find { |c| c['id'] == id }
    return community if community

    raise Koala::Facebook::ClientError.new(400, {}.to_json)
  end

  def community_feeds(_id, opts={})
    feeds = []
    2.times { |i| feeds << feed(i).merge(opts) }
    feeds
  end

  def feed(id = 'id')
    {
      'link' => 'https://link.to/the/feed',
      'msg' => 'This is the actual content of the feed 🎉',
      'id' => "feed_#{id}"
    }
  end

  def community_feed_comments_count(feed_id)
    @community_feed_comments ||= {}
    community_feed_comments[feed_id] || 0
  end
end
