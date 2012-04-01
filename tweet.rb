# -*- coding: utf-8 -*-

require "rubygems"
require "twitter"
require "yaml"
require "./create_message.rb"

class Tweet
  def initialize
    twitter_config = YAML.load_file("config.yml")

    Twitter.configure do |config|
      config.consumer_key       = twitter_config[:consumer_key]
      config.consumer_secret    = twitter_config[:consumer_secret]
      config.oauth_token        = twitter_config[:oauth_token]
      config.oauth_token_secret = twitter_config[:oauth_token_secret]
    end
  end
  
  def tweet_reply(tweet)
    if has_bot_name?(tweet)
      cm = CreateMessage.new
      msg = "@#{tweet.user.screen_name} " + cm.create_message(tweet.text)
      opt = get_in_reply_to(tweet)
      tweet_post(msg, opt)
    end
  end

  private

  def tweet_post(msg, opts={})
    begin
      Twitter.update(msg, opts)
    rescue => ex
      puts ex.class, ex.message
      puts "post できないよ...(´・ω・｀)"
    end
  end

  def has_bot_name?(tweet)
    return true if tweet.text.include?("@98twbot")
    return false
  end
  
  def get_in_reply_to(tweet)
    return { "in_reply_to_status_id" => tweet.id }
  end
end
