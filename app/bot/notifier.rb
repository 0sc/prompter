class Notifier
  include Facebook::Messenger

  def self.send_community_added_notice(psid:, name:, ref_link:)
    # Congrats you've successfully added xyz to the sure fire engagemnt diviner ;)
    # Now sitback and watch the magic happen
    # Oh, but before then, could share this link with your community members. Super important
    # href link:
  end

  def self.send_community_type_changed_notice(psid:, pid:, name:, type:, info:)
    # The type of your community,name , has been changed to type by your admin. You can now fine tune the available feeds according to categories categories
    # cta
  end

  def self.send_community_removed_notice(psid:, name:)
    # Your xyz admin has pulled the plug on your subscription. You'll no longer receive updates on posts.
    # Help me protest this by sending them a message ;)
    ## cta
  end

  def self.send_community_profile_deleted_notice(psid:, name:)
    # You've successfully deleted your subscription to xyz. You'll no longer receive notifications of what's happening in the community
    # cta default to add more
  end

  def self.send_community_profile_updated_notice(psid:, info:)
    # You successfully update you xzy subscription to list categories.
    # cta default to add more
  end

  def self.send_access_token_expiring_notice(psid:, num_admin_comms:)
    # Hey, panic emoji my access token for pulling feeds on your behalf for
    # is about to expire. Could you follow the link below to help me renew it
  end

  def self.send_access_token_expired_notice(psid:, num_admin_comms:)
    # Ahh, your access token has expired; now your community members subscribed to helping with posts will no longer be updated.
    # But no worries, let's work together and fix it
    # login cta
  end
end
