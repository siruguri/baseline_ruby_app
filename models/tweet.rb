class Tweet
  class Item
    def initialize
      @list = []
    end
    attr_accessor :list
    def type(sym)
      @list.select { |i| i[:type] == sym }
    end
  end
  
  include Mongoid::Document
  field :tweet_id, type: BigDecimal
  field :retweet, type: Integer
  field :replies, type: Integer
  field :likes, type: Integer
  field :urls, type: Array
  field :hashtags, type: Array
  field :md5, type: String
  field :source_search, type: String
  field :tweet_link, type: String
  
  index({source_search: 1})

  def self.upsert_list(l)
    i = Item.new
    l.each do |item|
      if ((t=Tweet.where(md5: item[:md5])).count) > 0
        puts "Found #{item[:md5]}"
        t1 = Tweet.find_by md5: item[:md5]
        t1.update_attributes retweet: item[:retweet], likes: item[:likes], replies: item[:replies]

        i.list << {tweet: t1, type: :old}
        t1
      else
        t = Tweet.create item
        i.list << {tweet: t, type: :new}
        t
      end
    end

    i
  end
end
