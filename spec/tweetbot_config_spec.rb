require_relative '../lib/tweetbot'

describe "configuring tweetbot with a config block" do

  context "configuring twice" do
    it "uses the same bot" do
      bot1 = TweetBot.configure do |bot|
        bot.response_frequency = 4
      end

      bot2 = TweetBot.configure do |bot|
        bot.response_frequency = 10
      end

      bot1.should be(bot2)
      bot1.response_frequency.should == 10
    end
  end

  context "configuring frequency" do
    let(:bot) do
      TweetBot.configure do |bot|
        bot.response_frequency = 4
      end
    end

    it "saves the response_frequency" do
      bot.response_frequency.should == 4
    end
  end

  context "configuring responses" do
    let(:bot) do
      TweetBot.configure do |bot|
        bot.respond_to_phrase "code and coffee" do |responses|
          responses << "good times" << "bad times"
        end
      end
    end

    it "saves the response given in block" do
      bot.stub(:rand) { 0 }
      response = bot.response_for(stub(:text => "code and coffee", :user => stub.as_null_object))
      response.should =~ /good times$/
      bot.stub(:rand) { 1 }
      response = bot.response_for(stub(:text => "code and coffee", :user => stub.as_null_object))
      response.should =~ /bad times$/
    end
  end

  context "without a configure block" do
    it "returns a bot that I can use" do
      bot = TweetBot.configure
      bot.response_frequency = 4
      bot.response_frequency.should == 4
    end
  end
end
