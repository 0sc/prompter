require 'clockwork'
require 'active_support/time'

module Clockwork
  every(4.minutes, 'Trigger the check community feeds') do
    system('rails check:community_feeds')
  end
end
