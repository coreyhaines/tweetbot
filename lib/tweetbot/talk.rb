require 'twitter'

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
    def configure_streaming_twitter
      Twitter::Streaming::Client.new do |config|
        config.consumer_key = twitter_auth[:consumer_key]
        config.consumer_secret = twitter_auth[:consumer_secret]
        config.access_token = twitter_auth[:access_token]
        config.access_token_secret = twitter_auth[:access_token_secret]
      end
    end

    def configure_rest_twitter_client
      Twitter::REST::Client.new do |config|
        config.consumer_key = twitter_auth[:consumer_key]
        config.consumer_secret = twitter_auth[:consumer_secret]
        config.access_token = twitter_auth[:access_token]
        config.access_token_secret = twitter_auth[:access_token_secret]
      end
    end

    def talk
      client = configure_streaming_twitter

      bot = self

      announce_wake_up
      puts "Listening... #{Time.now}"

      ["INT", "TERM"].each do |signal|
        trap(signal) do
          puts "Got #{signal}"
          exit!(1)
        end
      end

      at_exit do
        puts "Shutting down... #{Time.now}"
        begin
          # send_twitter_message "Going to sleep... #{Time.now}"
        rescue
        end
      end



      client.filter(track: bot.phrases_to_search.join(",")) do |status|
        puts status.text if status.is_a?(Twitter::Tweet)
        #if status.user.screen_name.downcase == TwitterAuth::MyName.downcase
          #puts "#{Time.now} Caught myself saying it"
        #else
          puts "#{Time.now} #{status.user.screen_name} said #{status.text}"
          if bot.should_i_respond_to?(status)
            response = bot.response_for(status)
            begin
              send_twitter_message(response, :in_reply_to_status_id => status.id)
              puts "Responding"
            rescue Twitter::Error::Forbidden => ex
              puts "Rate limited!"
              bot.rate_limited!
            rescue Exception => ex
              puts "Exception while sending the reply"
              puts ex
            end
          else
            puts "Bot told me not to respond"
          end
          begin
            bot.alert_status_captured(status)
          rescue => ex
            puts "Exception while alerting status"
            puts ex
          end
        #end
      end
    end

    def send_twitter_message(message, options = {})
      client = configure_rest_twitter_client
      client.update message, options
    end

    def announce_wake_up
      puts "Waking up to greet the world... #{Time.now}"
      # send_twitter_message "Waking up to greet the world... #{Time.now}"
    rescue Twitter::Error::Forbidden => ex
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
