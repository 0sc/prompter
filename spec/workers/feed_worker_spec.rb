require 'rails_helper'
require 'support/dummy_facebook_service'

RSpec.describe FeedWorker, type: :worker do
  let(:dummy_service) { DummyFacebookService.new }
  let(:community_one) { create(:community) }
  let(:community_two) { create(:community) }
  let(:user_one) { create(:user, expires_at: 5.days.from_now) }
  let(:user_two) { create(:user, expires_at: 5.years.from_now) }
  let(:msg) { dummy_service.feed['message'] }
  let(:link) { dummy_service.feed['link'] }

  before do
    stub_const('FacebookService', dummy_service)
    user_one.admin_profile.add_community(community_one)
    user_two.admin_profile.add_community(community_two)
  end

  describe 'queueing the job' do
    context 'eligible community' do
      describe 'queued feed' do
        let(:feeds_count) { dummy_service.community_feeds(nil).count }
        let(:exp_tally) { Hash.new }

        before do
          FeedWorker.perform_async
          expect(FeedWorker.jobs.size).to eq 1
          expect(FeedWorker.jobs.first['args']).to be_empty
        end

        it 'does not queue feed if it has more than 1 comment' do
          dummy_service.community_feed_comments = { 'feed_1' => 3,
                                                    'feed_2' => 2 }

          FeedWorker.drain
          expect(AnalysisWorker.jobs.size).to eq 2

          tally = Hash.new { |hash, key| hash[key] = 0 }
          exp_tally[[community_two.fbid, msg, link]] = feeds_count - 1
          exp_tally[[community_one.fbid, msg, link]] = feeds_count - 1

          AnalysisWorker.jobs.each do |job|
            tally[job['args']] += 1
          end

          expect(tally).to eq exp_tally
        end

        it 'queues feed if it has less than comment' do
          dummy_service.community_feed_comments = { 'feed_1' => 0,
                                                    'feed_2' => 1 }

          FeedWorker.drain
          expect(AnalysisWorker.jobs.size).to eq 4

          tally = Hash.new { |hash, key| hash[key] = 0 }
          exp_tally[[community_two.fbid, msg, link]] = feeds_count
          exp_tally[[community_one.fbid, msg, link]] = feeds_count

          AnalysisWorker.jobs.each do |job|
            tally[job['args']] += 1
          end

          expect(tally).to eq exp_tally
        end
      end
    end

    context 'community is not subscribable' do
      before { community_two.update!(community_type: nil) }

      it 'does not queue a job if community is not subscribable' do
        FeedWorker.perform_async
        expect(FeedWorker.jobs.size).to eq 1
        expect(FeedWorker.jobs.first['args']).to be_empty

        FeedWorker.drain
        expect(AnalysisWorker.jobs.size).to eq 2

        AnalysisWorker.jobs.each do |job|
          expect(job['args']).to match_array [community_one.fbid, msg, link]
        end
      end
    end

    context 'community admins token will expire' do
      before do
        user_one.update(expires_at: 10.minutes.ago.to_i)
        user_two.update(expires_at: 29.minutes.from_now.to_i)
      end

      it 'does not queue a job if community admin token will expire in 30min' do
        FeedWorker.perform_async
        expect(FeedWorker.jobs.size).to eq 1
        expect(FeedWorker.jobs.first['args']).to be_empty

        FeedWorker.drain
        expect(AnalysisWorker.jobs.size).to eq 0
      end

      it 'for multiple admin it queues if any valid token is present' do
        user_three = create(:user, expires_at: 35.minutes.from_now)
        user_three.admin_profile.add_community(community_two)

        FeedWorker.perform_async
        expect(FeedWorker.jobs.size).to eq 1
        expect(FeedWorker.jobs.first['args']).to be_empty

        FeedWorker.drain
        expect(AnalysisWorker.jobs.size).to eq 2

        AnalysisWorker.jobs.each do |job|
          expect(job['args']).to match_array [community_two.fbid, msg, link]
        end
      end
    end

    context 'community has multiple admins' do
      before do
        user_one.admin_profile.add_community(community_two)
        user_two.admin_profile.add_community(community_one)

        [community_one, community_two].each do |community|
          expect(community.admin_profiles)
            .to match_array([user_one.admin_profile, user_two.admin_profile])
        end
      end

      it 'does not double queue a job for the community' do
        FeedWorker.perform_async
        expect(FeedWorker.jobs.size).to eq 1
        expect(FeedWorker.jobs.first['args']).to be_empty

        FeedWorker.drain
        expect(AnalysisWorker.jobs.size).to eq 4

        tally = Hash.new { |hash, key| hash[key] = 0 }
        exp_tally = {}
        exp_tally[[community_two.fbid, msg, link]] = 2
        exp_tally[[community_one.fbid, msg, link]] = 2

        AnalysisWorker.jobs.each do |job|
          tally[job['args']] += 1
        end

        expect(tally).to eq exp_tally
      end
    end
  end
end
