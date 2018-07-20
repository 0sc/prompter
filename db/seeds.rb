ActiveRecord::Base.transaction do
  # Community Types
  community_type_names = %i[technology entertainment]
  community_types = community_type_names.map do |name|
    CommunityType.find_or_create_by!(name: name)
  end

  # Feed Categories
  feed_categories = {
    'machine learning'      => [community_types[0]],
    'artifical inteligence' => [community_types[0]],
    'data science'          => [community_types[0]],
    'design'                => [community_types[0]],
    'ruby'                  => [community_types[0]],
    'go'                    => [community_types[0]],
    'javascript'            => [community_types[0]],
    'react'                 => [community_types[0]],
    'android'               => [community_types[0]],
    'typescript'            => [community_types[0]],
    'php'                   => [community_types[0]],
    'laravel'               => [community_types[0]],
    'python'                => [community_types[0]],

    'Movies'                => [community_types[1]],
    'Music'                 => [community_types[1]],
    'TV Shows'              => [community_types[1]],
    'Anime'                 => [community_types[1]],
    'Awards'                => [community_types[1]],
    'Celebrity'             => [community_types[1]],

    'uncategorised'         => community_types
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
