ActiveRecord::Base.transaction do
  # Community Types
  community_type_names = %i[technology crypocurrency]
  community_types = community_type_names.map do |name|
    CommunityType.find_or_create_by!(name: name)
  end

  # Feed Categories
  feed_categories = {
    'machine learning'      => [community_types[0]],
    'artifical inteligence' => [community_types[0]],
    'Virtual Reality'       => [community_types[0]],
    'Argumented Reality'    => [community_types[0]],
    'data science'          => [community_types[0]],
    'design'                => [community_types[0]],
    'blockchain'            => [community_types[0]],
    'programing-css'        => [community_types[0]],
    'programing-html'       => [community_types[0]],
    'programing-ruby'       => [community_types[0]],
    'programing-rails'      => [community_types[0]],
    'programing-go'         => [community_types[0]],
    'programing-javascript' => [community_types[0]],
    'programing-react'      => [community_types[0]],
    'programing-angular'    => [community_types[0]],
    'programing-typescript' => [community_types[0]],
    'programing-php'        => [community_types[0]],
    'programing-laravel'    => [community_types[0]],
    'programing-python'     => [community_types[0]],
    'programing-django'     => [community_types[0]],

    'Bitcoin'               => [community_types[1]],
    'Ethereum'              => [community_types[1]],
    'Cardano'               => [community_types[1]],
    'Proof of work'         => [community_types[1]],
    'Proof of stake'        => [community_types[1]],

    'unclassified'          => community_types
  }

  feed_categories.each do |name, c_types|
    feed_category = FeedCategory.find_or_create_by!(name: name)
    c_types.map { |c_type| c_type.add_feed_category(feed_category) }
  end

  # remove old feed categories
  FeedCategory.where.not(name: feed_categories.keys).map(&:destroy)

  # remove old community_types
  CommunityType.where.not(id: community_type_names).map(&:destroy)
end
