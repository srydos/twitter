#!/usr/bin/env ruby
require 'yaml'
require WORK_DIR + './Class/TetesolTwitter'
require WORK_DIR + './Class/BotSetting.rb'
###
# bot用の条件文を定義するクラス
###
class TetesolBot < Array
  RANDOM_MAX = 5 #接頭語・接尾語を最大何回繰り返すかの数値
  EXPORT_TEXT_PATH = './Result/saved.txt' #saveを選んだ時追記するテキストファイル
  attr_accessor :client, :user
  #設定yamlから自身を規定し、起動
  def initialize(client_yml_path, setting_yaml_path)
    @client = TetesolTwitter.new(client_yml_path)
    @user = @client.user
    settings_array = YAML.load_file(setting_yaml_path)
    settings_array.each do |set|
      bot_setting = BotSetting.new(set[:condition], set[:reaction])
      self.unshift(bot_setting)
    end
  end

  #ツイートをもらってリアクションをするか判断する
  def reaction_tweet(tweet)
    self.each do |s|
      case s.condition.category
      when "reply"
        if tweet.in_reply_to_user_id == @user.name or tweet.full_text.include?("@#{@user.screen_name}")
          reaction(tweet, s.reactions) if has_text_in_tweet(tweet, s.condition.condition_texts)
        end
      when "timeline"
        reaction(tweet, s.reactions) if has_text_in_tweet(tweet, s.condition.condition_texts)
      when "self"
        if tweet.user == @my_twietter_id then
          reaction(tweet, s.reactions) if has_text_in_tweet(tweet, s.condition.condition_texts)
        end
      #以下はツイートからは判断しないため無視
      when "fav_me"
      when "fav"
      when "delete"
      when "follow"
      else
      end
    end
    tweet.id
  end

  #イベントを受け取ってリアクションをする
  def reaction_event(event)
    self.each do |s|
      case s.condition.category
      when "fav_me"
      when "fav"
      when "delete"
      when "follow"
      #以下はツイートのため無視
      when "reply"
      when "timeline"
      when "self"
      else
      end
    end
  end

  #ツイートのテキストに条件テキストが含まれるかチェック
  def has_text_in_tweet(tweet, text_arr)
    Array(text_arr).any? { |text| tweet.full_text.include?(text) }
  end

  #リアクション処理
  #@return tweet.id
  def reaction(tweet, reactions)
    Array(reactions).each do |rea|
      case rea.category
      when "reply"
        do_reply(tweet, rea)
      when "tweet"
        do_tweet(rea)
      when "delete"
        do_delete(tweet)
      when "fav"
        do_fav(tweet)
      when "follow"
        do_follow(tweet)
      when "log"
        save_log(tweet)
      else
      end
    end
    tweet.id
  end

  #リプライをする場合
  def do_reply(tweet, reaction)
    text = reaction_random_text(reaction)
    puts "reply text: #{text}"
    tweeted = @client.reply(tweet.id, text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  #何かしらのツイートをする場合 空リプ？
  def do_tweet(reaction)
    text = reaction_random_text(reaction)
    tweeted = @client.tweet(text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  #削除を試みる（当然自分のツイート以外は削除できない）
  def do_delete(tweet)
    @client.delete(tweet)
  end

  #該当ツイートをファボる
  def do_fav(tweet)
    @client.favorite(tweet)
  end

  #ツイートした人をフォローする
  def do_follow(tweet)
    @client.follow(tweet.user.id)
  end

  #該当ツイートを保存する
  def save_log(tweet)
    File.open(EXPORT_TEXT_PATH, 'a') do |file|
      file.puts(tweet.to_hash)
    end
  end

  #ツイートする際のランダム生成化
  def reaction_random_text(reaction)
    random_text_arr = []
    reaction.replies.each do |reply|
      repetition = reply.weight.nil?? 1 : reply.weight
      repetition .times do
        reply.reaction_texts.each do |reaction_text|
          text = reaction_text.clone
          Random.rand(0..RANDOM_MAX).times{ text.insert(0, reply.prefix) } if !reply.prefix.nil?
          Random.rand(0..RANDOM_MAX).times{ text        << reply.suffix  } if !reply.suffix.nil?
          random_text_arr << text
        end
      end
    end
    text = Array(random_text_arr).sample
    text
  end
end
