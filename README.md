# Tweetbot

So you want to write a twitter bot. Use my gem. Then, you can just do this:

```ruby
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
```

and build a file called twitter_auth.rb that has your keys

```
module TwitterAuth
  MyName = 'twitter_name'
  AuthKeys = {
    consumer_key: "key",
    consumer_secret: "secret",
    oauth_token: "token",
    oauth_token_secret: "token_secret"
  }
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tweetbot'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tweetbot

## Usage

So you want to write a twitter bot. Use my gem. Then, you can just do this:

```ruby
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
```

and build a file called twitter_auth.rb that has your keys

```
module TwitterAuth
  MyName = 'twitter_name'
  AuthKeys = {
    consumer_key: "key",
    consumer_secret: "secret",
    oauth_token: "token",
    oauth_token_secret: "token_secret"
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coreyhaines/tweetbot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/tweetbot/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tweetbot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tweetbot/blob/master/CODE_OF_CONDUCT.md).
