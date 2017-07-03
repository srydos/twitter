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
  #条件記述メソッド
  def reaction(material)
    @eval_entity = material

    pp material unless material.is_a?(Twitter::Streaming::FriendList)

    self.each do |setting|
      @eval_setting = setting
      case @eval_setting.condition.category
      when "reply"
        if tweet? && reply? && reply_to_me? && text_in_tweet?
          do_reaction
        end
      when "timeline"
        if tweet? && text_in_tweet?
          do_reaction
        end
      when "self"
        if tweet? && mine? && text_in_tweet?
          do_reaction
        end
      #以下はツイートからは判断しないため無視
      when "fav_me"
        if event? && fav? && fav_me?
          do_reaction
        end
      when "fav"
        if event? && fav?

          pp "fav!"

          do_reaction
        end
      when "delete"

        p event?
        p delete?
        if delete?
          pp @eval_entity.user_id
          pp @eval_entity.id
          pp @eval_entity.attrs
          user  = Twitter::User.new(material.attrs)
          tweet = Twitter::Tweet.new(material.attrs)
          pp tweet
          pp user
          @client.tweet_print_console(tweet)

          do_reaction
        end
      when "follow"
        if event?
          do_reaction
        end
      else
      end
    end
  end

  #ツイートリアクション処理
  #@return tweet.id
  def do_reaction
    Array(@eval_setting.reactions).each do |reaction|
      @eval_reaction = reaction
      Array(@eval_reaction.category).each do |category|
        case category
        when "reply"
          do_reply
        when "tweet"
          do_tweet
        when "delete"
          do_delete
        when "fav"
          do_fav
        when "follow"
          do_follow
        when "log"
          save_log
        else
        end
      end
    end
  end

  #リプライをする場合
  def do_reply
    text = reaction_random_text
    pp "dummy reply"
    pp text
    exit
    tweeted = @client.reply(@eval_entity.id, text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  #何かしらのツイートをする場合 空リプ？
  def do_tweet
    text = reaction_random_text
    tweeted = @client.tweet(text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  #削除を試みる（当然自分のツイート以外は削除できない）
  def do_delete
    @client.delete(@eval_entity)
  end

  #該当ツイートをファボる
  def do_fav
    @client.favorite(@eval_entity)
  end

  #ツイートした人をフォローする
  def do_follow
    @client.follow(@eval_entity.user.id)
  end

  #該当ツイートを保存する
  def save_log
    File.open(EXPORT_TEXT_PATH, 'a+') do |file|
      file.puts(@eval_entity.to_hash)
      file.puts(@client.tweet_print_console(@eval_entity))
    end
  end

  #ツイートする際のランダム生成化
  def reaction_random_text
    random_text_arr = []
    @eval_reaction.replies.each do |reply|
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
    Array(random_text_arr).sample
  end

  ###
  #条件式
  ###

  #ツイートかどうか
  def tweet?
    @eval_entity.is_a?(Twitter::Tweet)
  end

  #イベントかどうか
  def event?
    @eval_entity.is_a?(Twitter::Streaming::Event)
  end

  #リプライかどうか
  def reply?
    @eval_entity.in_reply_to_user_id
  end

  #リプライかどうか
  def retweet?
    @eval_entity.retweet?
  end

  #自分宛のリプライかどうか
  def reply_to_me?
    @eval_entity.in_reply_to_user_id == @user.name || @eval_entity.full_text.include?("@#{@user.screen_name}")
  end

  #自分のツイートかどうか
  def mine?
    @eval_entity.user.id == @user.id
  end

  #イベントかどうか
  def fav?
    @eval_entity.name == :favorite
  end

  #自分のツイートのお気に入りかどうか
  def fav_me?
    @eval_entity.user == @user.id
  end

  #ツイートの削除イベントかどうか
  def delete?
    @eval_entity.is_a?(Twitter::Streaming::DeletedTweet)
  end

  #ツイートのテキストに条件テキストが含まれるかチェック
  def text_in_tweet?
    text_arr = @eval_setting.condition.condition_texts
    return true if text_arr.empty? #条件なし == true
    Array(text_arr).any? { |text| @eval_entity.full_text.include?(text) }
  end
end
