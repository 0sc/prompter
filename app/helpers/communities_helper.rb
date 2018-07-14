module CommunitiesHelper
  def ref_link(code)
    ENV.fetch('BOT_URL') + '?ref=' + code
  end
end
