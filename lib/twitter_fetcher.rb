require 'uri'
class TwitterFetcher
  def query(q, type=nil)
    type_params = type.nil? ? '' : 'f=tweets&'
    puts ">>> Using #{type_params}"
    bot = NetHttpFetch.new
    bot.add_headers(cookie: 'guest_id=v1%3A145481670715445272; eu_cn=1; moments_profile_moments_nav_tooltip_self=true; moments_profile_moments_nav_tooltip_other=true; moments_moment_guide_create_moment_tooltip=true; twitter_ads_id=v1_711778974054002689; netpu="FpD/99z8VQA="; external_referer=padhuUp37zhm0otHWp6CQ5iLgqiCaIiw7sqKlATXUTDgOTeJjXulxYPn387BUDPfAf7RN0FlS7DHpxWlobLjkckfGw1C3ck47J+9mFDkeiPKTNCC6jSwkvlHXZIBnC6p6+e76mOY0RWFN9LsID9uFMzLkjfyXrs7FvKCqQs4eAjFWG1ShGyJ5SnPz1FDMhup|0; __utma=43838368.147818947.1455005271.1476763874.1477457050.4; __utmz=43838368.1473832708.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _gat=1; lang=en; kdt=72Zs2pDCAMA1nKzNru7xYc7i5kKFks6Z5FWFcvRP; remember_checked_on=0; twid="u=5036831"; auth_token=571d7fcc6bd9bed7c147b77cba25db3e8cc03420; pid="v3:1477676766849544493293574"; _ga=GA1.2.147818947.1455005271; _twitter_sess=BAh7CiIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNo%250ASGFzaHsABjoKQHVzZWR7ADoPY3JlYXRlZF9hdGwrCF3EWARYAToMY3NyZl9p%250AZCIlYmQyZmJiZjFhY2JhMDRlOTg4ZWRiNWNjNmZjYWM0MTM6B2lkIiU5YTNk%250AYWFlN2EyZDY4YzU2NGRiZjM5OTgyYzQ5MzZlNToJdXNlcmkDH9tM--0b06e42cc04d9190ceb9c0273cac9a25b49a0f7e',
                    referer: 'https://twitter.com/',
                    "user-agent" => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36)')
    
    content = bot.get("https://twitter.com/search?#{type_params}q=#{URI.escape(q)}&src=typd")[:body]

    # Split by the tweet div, and discard the first bit
    if (list = content.split(/li.class=.js.stream.(tweet|item)/)[1..-1]).size == 0
      puts 'Used alternate content format'
      list = content.split(/js.tweet.text/)[2..-1]
    end
    
    data = []
    list.each_with_index do |html_snippet, hs_idx|
      next if html_snippet=~/^\-container/ or html_snippet=~/^item$/
      if html_snippet =~ /js.action.profile.promoted/
        puts ">>> promotion"
        next
      end
        
      if (m = /data.tweet.id..(\d+)\"/.match(html_snippet)).nil?
        break
      else
        id = m[1]
      end
      
      cts = {}
      cts[:source_search] = q

      text_idx = text_start_index html_snippet
      url_match = html_snippet[text_idx..-1].split(/<a\s+href=\"/).map do |l|
        l.match(/data.expanded.url=\"([^"]+)/).try(:[], 1)
      end.compact.select { |u| (u=~/^http/).is_a?(Fixnum) and !(u=~/https...twitter.com/) }

      cts[:urls] = url_match.size > 0 ? url_match : []

      matches = html_snippet.split(/stat.count/)[1..-1].map { |i| i[0..10].scan(/\d+/) }.map { |i| i[0].to_i }
      cts[:replies] = matches[0]
      cts[:retweet] = matches[1]
      cts[:likes] = matches[2]

      cts[:hashtags] = hashtags(html_snippet)
      cts[:tweet_id] = id
      cts[:tweet_link] = "https://twitter.com/i/web/status/#{id}"
      cts[:md5] = Digest::MD5.new.update("#{cts[:tweet_id]}#{cts[:hashtag]}#{cts[:urls]}").hexdigest
      data << cts
    end
    data
  end

  private
  def text_start_index(str)
    str =~ /tweet.text/ || 0
  end
  
  def hashtags(string)
    text_idx = text_start_index string
    url_match = string[text_idx..-1].split(/<a\s+href=\"/).map do |l|
      l.match(/^([^"]+)/)[1]
    end.compact.map { |u| (/\/hashtag\/(.*)\?src.hash/).match(u).try(:[], 1) }.compact
  end
end
