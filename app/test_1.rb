module App
  class App
    def reset
      TweetRecommendation.all.map &:delete
    end
    
    def test1
      q = self.args[:query] || "#education #stem"
      request_type = self.args[:popular] ? nil : ''
      
      prev_tag = RunRecord.where(run_tag: 'twitter').order(run_at: :desc).first

      if prev_tag.nil? || prev_tag.run_at < Time.now #- 3.hours
        fetcher = TwitterFetcher.new
        urls = fetcher.query q, request_type
        upsert_resp = Tweet.upsert_list urls

        winner = upsert_resp.type(:new).
                 sort_by { |rec| rec[:tweet].retweet + rec[:tweet].likes + rec[:tweet].replies + rec[:tweet].urls.size }.select do |rec|
          rec[:tweet].urls.size > 0
        end

        r = RunRecord.new run_tag: 'twitter', run_at: Time.now, urls: urls.to_json
        r.save!

        unless winner.empty?
          ref_id = winner.last[:tweet].id
          unless TweetRecommendation.where(tweet_ref_id: ref_id).count > 0
            s = TweetRecommendation.new tweet_ref_id: ref_id, created_at: Time.now        
            s.save
          end
        end
        puts "-> #{RunRecord.count}"
        puts "-> #{Tweet.count}"
        puts "-> #{TweetRecommendation.count}"
      end
    end
    
    def test2
      TweetRecommendation.order_by(created_at: 'asc').all.each do |rec|
        t = rec.tweet
        if t.nil?
          rec.delete
        elsif (t.retweet + t.replies + t.likes) == 0 or t.hashtags.nil?
          t.delete
        else
          puts JSON.pretty_generate(JSON.parse(t.to_json)) if rec.created_at.present?
        end
      end
    end
  end
end
