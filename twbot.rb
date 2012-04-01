# -*- coding: utf-8 -*-

require "rubygems"
require "user_stream"
require "yaml"
require "./tweet.rb"


loop do
  twitter_config = YAML.load_file("config.yml")

  UserStream.configure do |config|
    config.consumer_key       = twitter_config[:consumer_key]
    config.consumer_secret    = twitter_config[:consumer_secret]
    config.oauth_token        = twitter_config[:oauth_token]
    config.oauth_token_secret = twitter_config[:oauth_token_secret]
  end
  
  begin
    twitter = Tweet.new

    client = UserStream.client
    client.user do |status|
      twitter.tweet_reply(status) if status.has_key?("text")
    end
  rescue Timeout::Error => ex
    puts ex.class, ex.message
  end
end
