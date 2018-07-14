namespace :check do
  desc 'checks for new feeds in subscribed communities'
  task community_feeds: :environment do
    FeedWorker.perform_async
  end

  desc 'checks for expiring and expired access tokens'
  task access_tokens: :environment do
    TokenTtlWorker.perform_async
  end
end
