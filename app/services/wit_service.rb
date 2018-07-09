class WitService
  attr_reader :client, :msg, :analysis

  def initialize(msg, client: nil)
    access_token = Rails.application.credentials.wit_access_token
    @client = client || Wit.new(access_token: access_token)
    @msg = msg
  end

  def analyse
    @analysis = client.message(msg)
  end

  def intent_value
    intent.dig('value')
  end

  def intent
    @intent ||=
      intents.inject { |a, b| a['confidence'] > b['confidence'] ? a : b }
  end

  def intents
    @intents ||= analysis.dig('entities', 'intent')
  end
end
