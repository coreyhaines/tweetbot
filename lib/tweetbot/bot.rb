module TweetBot
  class Bot
    include TweetBot::Talk
    attr_accessor :response_frequency, :twitter_auth

    DefaultFrequency = 20
    Noop = lambda {|status|}


    def initialize()
      self.response_frequency = DefaultFrequency
      @responses_for_phrases = Hash.new { |hash, key| hash[key] = [] }
      @blocks_for_phrases = {}
    end

    def on_status_captured(key, &block)
      @blocks_for_phrases[key] = block
    end

    def alert_status_captured(status)
      find_phrase_value(@blocks_for_phrases, status.text, Noop).call(status)
    end

    def phrases_to_search
      @responses_for_phrases.keys + @blocks_for_phrases.keys
    end

    def responses_for(phrase)
      @responses_for_phrases[phrase]
    end

    def respond_to_phrase(phrase)
      responses = []
      yield responses
      add_responses_for_phrase(phrase, *responses)
    end

    def add_responses_for_phrase(phrase, *responses)
      @responses_for_phrases[phrase.downcase] += responses
    end

    def response_for(tweet)
      responses = responses_for_tweet(tweet)
      "@#{tweet.user.screen_name} #{responses.sample}"
    end

    def should_i_respond_to?(tweet)
      if under_rate_limit_pause?
        puts "Under rate limit pause. Will let up at #{@rate_limited_until.to_s}"
        return false
      end
      matches = tweet_matches?(tweet)
      frequency_check = (rand(100) < self.response_frequency)
      matches && frequency_check
    end

    def rate_limited!
      puts "Starting rate limit throttling!"
      @rate_limited_until = Time.now + 3600
    end

    def under_rate_limit_pause?
      @rate_limited_until && (Time.now < @rate_limited_until)
    end

    def tweet_matches?(tweet)
      responses_for_tweet(tweet).any?
    end

    def responses_for_tweet(tweet)
      find_phrase_value(@responses_for_phrases, tweet.text, [])
    end

    def find_phrase_value(hash, text, default)
      hash.select { |phrase, _| text =~ /#{phrase.downcase}/i }.values[0] || default
    end

  end
end
