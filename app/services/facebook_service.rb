class FacebookService
  attr_reader :graph, :fbid

  def initialize(user_fbid, token)
    @graph = Koala::Facebook::API.new(token)
    @fbid = user_fbid
  end

  def community_details(community_id)
    graph.get_object("#{community_id}?fields=cover,name,icon")
  end

  def communities
    return @communities if @communities

    fields = %w[administrator name icon]
    @communities =
      all_results(graph.get_connections(fbid, 'groups', fields: fields))
  end

  def admin_communities
    @admin_communities ||= communities.select { |comm| comm['administrator'] }
  end

  def admin_communities_fbids
    admin_communities.map { |comm| comm['id'] }
  end

  def community_feeds(community_id)
    return @community_feeds if @community_feeds
    @community_feeds = all_results(
      graph.get_connections(community_id, 'feeds')
    )
  end

  def community_feed_comments(feed_id)
    graph.get_connections(feed_id, 'comments')
  end

  private

  def all_results(graph_results)
    results = graph_results.to_a
    while (graph_results = graph_results.next_page)
      results += graph_results.to_a
    end
    results
  end
end
