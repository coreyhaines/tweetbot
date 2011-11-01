require 'twitter'
require 'tweetstream'

if ENV["DEBUG"]
  module Twitter
    def self.configure
    end

    def self.update(status, options = {})
      puts "DEBUG: #{status}"
    end
  end
end
module TweetBot
  module Talk
    def configure_twitter_auth
      Twitter.configure do |config|
        config.consumer_key = twitter_auth[:consumer_key]
        config.consumer_secret = twitter_auth[:consumer_secret]
        config.oauth_token = twitter_auth[:oauth_token]
        config.oauth_token_secret = twitter_auth[:oauth_token_secret]
      end
      TweetStream.configure do |config|
        config.consumer_key = twitter_auth[:consumer_key]
        config.consumer_secret = twitter_auth[:consumer_secret]
        config.oauth_token = twitter_auth[:oauth_token]
        config.oauth_token_secret = twitter_auth[:oauth_token_secret]
        config.auth_method = :oauth
      end
    end

    def talk
      configure_twitter_auth

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

      announce_wake_up
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
          send_twitter_message "Going to sleep... #{Time.now}"
        rescue
        end
      end


      client.on_error do |message|
        puts "Error: #{Time.now}"
        puts message
      end

      #EM.defer
      #EM::HttpRequest
      client.track(*bot.phrases_to_search) do |status|
        if status.user.screen_name.downcase == TwitterAuth::MyName.downcase
          puts "#{Time.now} Caught myself saying it"
        else
          puts "#{Time.now} #{status.user.screen_name} said #{status.text}"
          if bot.should_i_respond_to?(status)
            response = bot.response_for(status)
            begin
              send_twitter_message(response, :in_reply_to_status_id => status.id)
              puts "Responding"
            rescue Twitter::Forbidden => ex
              puts "Rate limited!"
              bot.rate_limited!
            rescue Exception => e
              puts "Exception while sending the reply"
              puts e
            end
          else
            puts "Bot told me not to respond"
          end
          bot.alert_status_captured(status)
        end
      end
    end

    def send_twitter_message(message, options = {})
      Twitter.update message, options
    end

    def announce_wake_up
      puts "Waking up to greet the world... #{Time.now}"
      send_twitter_message "Waking up to greet the world... #{Time.now}"
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
  end
end
