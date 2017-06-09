#!/usr/bin/env ruby
require 'yaml'
require WORK_DIR + './Class/TetesolTwitter'
require WORK_DIR + './Class/BotSetting.rb'
###
# bot用の条件文を定義するクラス
###
class TetesolBot < Array
  attr_accessor :client
  #設定yamlから自身を規定し、起動
  def initialize(client_yml_path, setting_yaml_path)
    @client = TetesolTwitter.new(client_yml_path)
    settings_array = YAML.load_file(setting_yaml_path)
    settings_array.each do |set|
      bot_setting = BotSetting.new(set[:condition],set[:reaction])
      self.unshift(bot_setting)
    end
    self.each do |s| 
      pp s.condition.category
    end
  end

  #ツイートオブジェクトをもらってリアクションをする
  def reaction_tweet(tweet)
    
  end

  #イベントを受け取ってリアクションをする
  def reaction_event(event)
  end
end
