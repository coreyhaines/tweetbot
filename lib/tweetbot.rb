require_relative 'tweetbot/version'
require_relative 'tweetbot/talk'
require_relative 'tweetbot/bot'

module TweetBot
  def self.configure
    @bot ||= Bot.new
    yield @bot if block_given?
    @bot
  end
end
