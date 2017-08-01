#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require 'date'
require_relative 'Class/tetesol_twitter'
twitter_user = TetesolTwitter.new(WORK_DIR + '/Config/trend-user.yml')

###
# トレンドを表示
# 日本2345896
###
trends_local_plane = twitter_user.local_trends(23_424_856)
trends_hash = {}
trend_data  = []
trends_hash['Time'] = Time.now
# hash in array in jsonの入れ子になっている
trends_local_plane.to_hash[:trends].each do |hash|
  #:urlは:queryと実質中身が同じなので取り除く
  hash.delete(:url)
  trend_data << hash
end
trends_hash['data'] = trend_data
twitter_user.tweet_to_yaml(trends_hash, './Result/data-trend.yml')
