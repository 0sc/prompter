class TokenTtlWorker
  include Sidekiq::Worker

  def perform
    # TODO: consider sending email notifications where psid is missing
    # TODO: consider unsubscribing communities with expired tokens
    each_user_with_just_expired_token do |user|
      num = user.admin_profile_community_count
      Notifier.send_access_token_expired_notice(
        psid: user.psid, num_admin_comms: num
      )
    end

    each_user_with_expiring_token do |user|
      num = user.admin_profile_community_count
      Notifier.send_access_token_expiring_notice(
        psid: user.psid, num_admin_comms: num
      )
    end
  end

  private

  def each_user_with_just_expired_token(&blk)
    raise 'I need a block' unless block_given?
    range = 1.hour.ago.to_i
    now = Time.current.to_i

    User
      .where(expires_at: range..now)
      .where.not(psid: nil)
      .find_each(&blk)
  end

  def each_user_with_expiring_token(&blk)
    raise 'I need a block' unless block_given?
    range = 2.days.from_now.to_i
    now = Time.current.to_i

    User
      .where(expires_at: now..range)
      .where.not(psid: nil)
      .find_each(&blk)
  end
end

### runs every day
