load 'twitter_auth.rb'
require 'tweetbot'

bot = TweetBot.configure do |config|
  config.response_frequency = 100

  config.respond_to_phrase "#rubyconfbot" do |responses|
    responses << "Enjoy RubyConf"
  end

  config.twitter_auth = TwitterAuth::AuthKeys
end

bot.talk

