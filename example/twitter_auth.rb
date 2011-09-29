module TwitterAuth
  MyName = 'twitter_name'
  ApigeeEnpoint = nil
  def self.use_apigee?
    !ApigeeEnpoint.nil?
  end
  AuthKeys = {
    consumer_key: "key",
    consumer_key_secret: "secret",
    oauth_token: "token",
    oauth_token_secret: "token_secret"
  }
end
