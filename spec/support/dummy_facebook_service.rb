class DummyFacebookService
  attr_accessor :admin_communities,
                :admin_communities_fbids

  def new(fbid, token)
    @fbid = fbid
    @token = token
    self
  end

  def community_details(id)
    raise Koala::Facebook::ClientError.new(400, {}.to_json) if id == '404'
    { 'name' => 'Asgard' }
  end
end
