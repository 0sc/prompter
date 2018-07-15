class Listener
  include Facebook::Messenger

  Bot.on :message do |message|
    klass = quick_reply?(message) ? 'QuickReply' : 'Message'
    "::Chat::#{klass}Service".constantize.new(message).handle
  end

  Bot.on :account_linking do |account|
    ::Chat::AccountLinkService.new(account).handle
  end

  Bot.on :postback do |postback|
    ::Chat::PostbackService.new(postback).handle
  end

  Bot.on :referral do |referral|
    ::Chat::ReferralService.new(referral).handle
  end

  def self.quick_reply?(message)
    message.messaging.dig('message').key? 'quick_reply'
  end
end
