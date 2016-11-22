class TweetRecommendation
  include Mongoid::Document

  field :created_at, type: DateTime
  field :tweet_ref_id, type: String
  def tweet
    Tweet.where(id: self.tweet_ref_id).first
  end
end
