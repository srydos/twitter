#!/usr/bin/env ruby
require 'date' 
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
twitter_user = TetesolTwitter.new('Config/trend-user.yml')
#トレンドを表示 日本2345896 
trends_local_plane = twitter_user.local_trends( 23424856 )
trends_hash = {}
trend_data  = []
trends_hash["Time"] = Time.now
#hash in array in jsonの入れ子になっている
trends_local_plane.to_hash[:trends].each do | hash |
  #:urlは:queryと実質中身が同じなので取り除く
  hash.delete(:url)
  trend_data << hash
end
trends_hash["data"] = trend_data
twitter_user.tweet_print_yaml( trends_hash, "./Result/data-trend.yml")
