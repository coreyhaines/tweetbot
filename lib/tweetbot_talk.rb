if ENV["DEBUG"]
  module Twitter
    def self.configure
    end

    def self.update(status, options = {})
      puts "DEBUG: #{status}"
    end
  end
end
module TweetBotTalk
  def talk
    require 'twitter'
    require 'tweetstream'
    load 'twitter_auth.rb'


    TweetStream.configure do |config|
      config.consumer_key = ConsumerKey
      config.consumer_secret = ConsumerSecret
      config.oauth_token = OAuthToken
      config.oauth_token_secret = OAuthTokenSecret
      config.auth_method = :oauth
    end
    Twitter.configure do |config|
      config.consumer_key = ConsumerKey
      config.consumer_secret = ConsumerSecret
      config.oauth_token = OAuthToken
      config.oauth_token_secret = OAuthTokenSecret
    end

    if TwitterAuth.use_apigee?
      twitter_api_endpoint = if ENV['APIGEE_TWITTER_API_ENDPOINT']
                               ENV['APIGEE_TWITTER_API_ENDPOINT']
                             else
                               # Get this value from Heroku.
                               # Once you have enabled the addon, boot up the 'heroku console' and run the following:
                               # puts ENV['APIGEE_TWITTER_API_ENDPOINT']
                               # this will spit out your correct api endpoint
                               TwitterAuth::ApigeeEnpoint
                             end
      Twitter.configure do |config|
        config.gateway = twitter_api_endpoint
      end
    end

    bot = self

    puts "Waking up to greet the world... #{Time.now}"
    begin
      Twitter.update "Waking up to greet the world... #{Time.now}"
    rescue Twitter::Forbidden => ex
      puts "Twitter Forbidden Error while waking up"
      puts ex
      puts "Continuing"
    rescue Twitter::Error => ex
      puts "Twitter Error while waking up"
      puts ex
      exit!(1)
    rescue => ex
      puts "Unknown Error while waking up"
      puts ex
      exit!(1)
    end
    puts "Listening... #{Time.now}"


    client = TweetStream::Client.new

    ["INT", "TERM", "STOP"].each do |signal|
      trap(signal) do
        puts "Got #{signal}"
        client.stop
        exit!(1)
      end
    end

    at_exit do
      puts "Shutting down... #{Time.now}"
      begin
        Twitter.update "Going to sleep... #{Time.now}"
      rescue
      end
    end


    client.on_error do |message|
      puts "Error: #{Time.now}"
      puts message
    end

    client.track(*bot.phrases_to_search) do |status|
      if status.user.screen_name == TwitterAuth::MyName
        puts "#{Time.now} Caught myself saying it"
      else
        puts "#{Time.now} #{status.user.screen_name} said #{status.text}"
        if bot.should_i_respond_to?(status)
          begin
            response = bot.response_for(status)
            Twitter.update "#{response}", :in_reply_to_status_id => status.id
          rescue Exception => e
            puts "Exception while sending the reply"
            puts e
          end
        else
          puts "Bot told me not to respond"
        end
      end
    end
  end
end
