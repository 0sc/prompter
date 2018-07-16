require 'clockwork'
require 'active_support/time'

module Clockwork
  every(3.hours, 'Trigger the check community feeds', at: '**:30') do
    system('rails check:community_feeds')
  end
end
