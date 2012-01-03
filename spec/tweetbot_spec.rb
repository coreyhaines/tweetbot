require_relative '../lib/tweetbot'
require 'timecop'


describe TweetBot::Bot do
  let(:bot) { TweetBot::Bot.new }
  let(:tweet) { stub(:text => "hello world", :user => stub(:screen_name => "fun_person")) }

  before do
    bot.add_responses_for_phrase "hello world", "and hello to you"
  end

  after do
    Timecop.return
  end


  describe "#phrases_to_search" do
    it "returns the phrases that have responses associated with them" do
      bot.add_responses_for_phrase "good night", ""
      bot.phrases_to_search.should == ["hello world", "good night"]
    end
  end

  describe "#tweet_matches?" do
    before do
      bot.add_responses_for_phrase "the night", "a dark night"
    end
    it "looks to see if any phrases match the tweet" do
      tweet.stub(:text) { "the night" }
      bot.tweet_matches?(tweet).should be_true
      tweet.stub(:text) { "the day" }
      bot.tweet_matches?(tweet).should be_false
    end

    it "compares case-insensitive" do
      tweet.stub(:text) { "The Night"}
      bot.tweet_matches?(tweet).should be_true
    end

    it "matches if anywhere in text" do
      tweet.stub(:text) { "It is cold The Night"}
      bot.tweet_matches?(tweet).should be_true
    end
  end

  describe "#tweet_matches_filters?" do
    before do
      bot.add_reasons_for_filter "the night", "a dark night"
    end
    it "looks to see if any phrases match the tweet" do
      tweet.stub(:text) { "the night" }
      bot.tweet_matches_filters?(tweet).should be_true
      tweet.stub(:text) { "the day" }
      bot.tweet_matches_filters?(tweet).should be_false
    end

    it "compares case-insensitive" do
      tweet.stub(:text) { "The Night"}
      bot.tweet_matches_filters?(tweet).should be_true
    end

    it "matches if anywhere in text" do
      tweet.stub(:text) { "It is cold The Night"}
      bot.tweet_matches_filters?(tweet).should be_true
    end

  end

  describe "#tweet_matches_filters? regex encodings" do
    before do
      bot.add_reasons_for_filter /\@\S+/, "filtering out a user reference"
    end

    it "matches conversation indicator anywhere in text" do
      tweet.stub(:text) {"@corey do not fear the night"}
      bot.tweet_matches_filters?(tweet).should be_true
    end
  end

  describe "#response_for" do
    it "replies to the user" do
      tweet.user.stub(:screen_name) { "corey" }
      bot.response_for(tweet).should =~ /^@corey/
    end

    it "uses responses associated with phrase" do
      bot.add_responses_for_phrase("good morning", "morning response")
      bot.add_responses_for_phrase("good night", "night response")

      tweet.stub(:text) { "good morning" }
      bot.response_for(tweet).should =~ /morning response/
      tweet.stub(:text) { "good night" }
      bot.response_for(tweet).should =~ /night response/
    end

    it "uses a random phrase from the responses" do
      tweet.stub(:text) { "good morning" }
      bot.add_responses_for_phrase("good morning", "response 1", "response 2")
      responses = (1..20).map do
        bot.response_for(tweet)
      end
      responses.reject! {|response| response =~ /response 1/}
      responses.should_not be_empty
      responses.reject! {|response| response =~ /response 2/}
      responses.should be_empty
    end

    it "uses responses if phrase appears anywhere in tweet (case-insensitive)" do
      bot.add_responses_for_phrase("good afternoon", "afternoon response")
      tweet.stub(:text) { "this is a Good Afternoon" }
      bot.response_for(tweet).should =~ /afternoon response/
    end
  end

  describe "#should_i_respond_to?" do
    before do
      bot.stub(:rand) { 1 }
      bot.stub(:tweet_matches?) { true }
      bot.stub(:tweet_matches_filters?) { false }
    end

    context "Under rate limit" do
      let(:now) { Time.now }
      let(:status) { stub }
      before do
        Timecop.freeze(now)
        bot.rate_limited!
      end

      it "won't allow response for 1 hour" do
        bot.should_i_respond_to?(status).should be_false
        Timecop.travel(now + 60 * 59) do
          bot.should_i_respond_to?(status).should be_false
        end
      end

      it "will allow response after an hour" do
        Timecop.travel(now + 3600) do
          bot.should_i_respond_to?(status).should be_true
        end
      end
    end

    it "only responds if rand is less than response_frequency" do
      bot.response_frequency = 30
      bot.stub(:rand) { 29 }
      bot.should_i_respond_to?(stub).should be_true
      bot.stub(:rand) { 30 }
      bot.should_i_respond_to?(stub).should be_false
      bot.stub(:rand) { 31 }
      bot.should_i_respond_to?(stub).should be_false
    end

    it "only responds if phrase matches" do
      bot.stub(:tweet_matches?) { true }
      bot.should_i_respond_to?(stub).should be_true
      bot.stub(:tweet_matches?) { false }
      bot.should_i_respond_to?(stub).should be_false
    end

    it "only responds if phrase matches and filter does not" do
      bot.stub(:tweet_matches?) { true }
      bot.stub(:tweet_matches_filters?) { false }
      bot.should_i_respond_to?(stub).should be_true
      bot.stub(:tweet_matches?) { true }
      bot.stub(:tweet_matches_filters?) { true }
      bot.should_i_respond_to?(stub).should be_false

    end
  end

  describe "#respond_to_phrase" do
    it "stores the given responses" do
      bot.respond_to_phrase "morning fun" do |responses|
        responses << "evening delight" << "afternoon rockets"
      end
      bot.responses_for_tweet(stub(:text => "morning fun")).should =~ ["evening delight", "afternoon rockets"]
    end
  end
end
