require 'tweetbot/version'
require_relative 'tweetbot_talk'

class TweetBot
  include TweetBotTalk
  attr_accessor :response_frequency

  def self.configure
    bot = new
    yield bot if block_given?
    bot
  end

  def initialize()
    self.response_frequency = 20
    @responses_for_phrases = Hash.new { |hash, key| hash[key] = [] }
  end

  def phrases_to_search
    @responses_for_phrases.keys
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
    "@#{tweet.user.screen_name} #{responses[rand(responses.length)]}"
  end

  def should_i_respond_to?(tweet)
    matches = tweet_matches?(tweet)
    frequency_check = (rand(100) < self.response_frequency)
    matches && frequency_check
  end

  def tweet_matches?(tweet)
    responses_for_tweet(tweet).any?
  end

  def responses_for_tweet(tweet)
    @responses_for_phrases.select{|phrase, _| tweet.text =~ /#{phrase}/i}.values[0] || []
  end
end
