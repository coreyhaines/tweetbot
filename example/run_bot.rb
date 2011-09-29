load 'twitter_auth.rb'
require 'tweetbot'

bot = TweetBot.configure do |config|
  config.response_frequency = 100

  config.respond_to_phrase "tweetbot example phrase" do |responses|
    responses << "I am tweetbot!" << "You rang?" << "Pretty cool, thanks for saying hello"
  end

  config.respond_to_phrase "hey @tweetbot" do |responses|
    responses << "Hey back at ya" << "You rang again?"
  end

  config.twitter_auth = TwitterAuth::AuthKeys
end

bot.talk

