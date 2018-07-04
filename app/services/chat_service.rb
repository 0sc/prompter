class ChatService
  attr_reader :user, :message

  def initialize(message)
    @message = message

    @user = User.find_or_initialize_by(psid: sender_id)
    # TODO: should the user details be always updated?
    user.update_from_psid! if user.new_record?
  end

  def sender_id
    message.sender['id']
  end

  def username
    user.first_name
  end

  def default_cta_options
    options = [Chat::QuickReply::FIND_COMMUNITIES,
               Chat::QuickReply::SUBSCRIBE_COMMUNITIES]
    options << Chat::QuickReply::MANAGE_COMMUNITIES if user.subscriptions?
    options
  end
end
