class DummyFacebookService
  attr_accessor :admin_communities,
                :admin_communities_fbids,
                :communities

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
end
