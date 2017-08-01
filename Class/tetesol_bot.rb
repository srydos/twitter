# frozen_string_literal: true

require 'yaml'
require_relative 'tetesol_twitter'
require_relative 'tetesol_streaming'
# bot用の条件文を定義するクラス
class TetesolBot
  RANDOM_MAX = 5 # 接頭語・接尾語を最大何回繰り返すかの数値
  EXPORT_TEXT_PATH = './Result/saved.txt' # saveを選んだ時追記するテキストファイル
  attr_accessor :client, :user
  # 設定yamlから自身を規定し、起動
  def initialize(client_yml_path, setting_yaml_path)
    @setting_yaml_path = setting_yaml_path
    @client = TetesolTwitter.new(client_yml_path)
    @user = @client.user
    settings_array = YAML.load_file(@setting_yaml_path)
    @settings = []
    settings_array.each do |set|
      bot_setting = BotSetting.new(set[:condition], set[:reaction])
      @settings << bot_setting
    end
  end

  # ツイートをもらってリアクションをするか判断する
  # 条件記述メソッド
  def reaction(material)
    puts @eval_entity = material
    return nil if material.is_a?(Twitter::Streaming::FriendList)
    @settings.lazy.each do |setting|
      @eval_setting = setting
      case @eval_setting.condition.category
      when 'reply'
        do_reaction if [tweet?, reply?, reply_to_me?, text_in_tweet?].all?
      when 'timeline'
        do_reaction if [tweet?, text_in_tweet?].all?
      when '@settings'
        do_reaction if [tweet?, mine?, text_in_tweet?].all?
      when 'conversation'
        do_reaction if [tweet?, reply?, reply_to_me?, conbersation?,
                        text_in_tweet?].all?
      when 'fav_me'
        do_reaction if [event?, fav?, fav_me?].all?
      when 'fav'
        do_reaction if [event?, fav?].all?
      when 'delete'
        do_reaction if delete?
      when 'follow'
        do_reaction if [event?, follow?].all
      end
    end
  end

  private

  # ツイートリアクション処理
  # @return tweet.id
  def do_reaction
    Array(@eval_setting.reactions).each do |reaction|
      @eval_reaction = reaction
      Array(@eval_reaction.category).each do |category|
        case category.to_sym
        when :reply
          do_reply
        when :tweet
          do_tweet
        when :delete
          do_delete
        when :fav
          do_fav
        when :follow
          do_follow
        when :log
          save_log
        when :reload
          do_reload
        end
      end
    end
  end

  # リプライをする場合
  def do_reply
    text = reaction_random_text
    pp 'dummy reply'
    pp text
    exit
    tweeted = @client.reply(@eval_entity.id, text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  # 何かしらのツイートをする場合 空リプ？
  def do_tweet
    text = reaction_random_text
    tweeted = @client.tweet(text)
    @client.tweet_print_console(tweeted)
    tweeted.id
  end

  # 削除を試みる（当然自分のツイート以外は削除できない）
  def do_delete
    @client.delete(@eval_entity)
  end

  # 該当ツイートをファボる
  def do_fav
    @client.favorite(@eval_entity)
  end

  # ツイートした人をフォローする
  def do_follow
    @client.follow(@eval_entity.user.id)
  end

  # 該当ツイートを保存する
  def save_log
    File.open(EXPORT_TEXT_PATH, 'a+') do |file|
      file.puts(@eval_entity.to_hash)
      file.puts(@client.tweet_print_console(@eval_entity))
    end
  end

  # 設定ファイルの再読込
  def do_reload
    @settings = []
    settings_array = YAML.load_file(@setting_yaml_path)
    settings_array.each do |set|
      bot_setting = BotSetting.new(set[:condition], set[:reaction])
      @settings << bot_setting
    end
  end

  # ツイートする際のランダムリターン
  # 渡された配列の重みを計算して、テキストを返す
  def reaction_random_text
    random_text_arr = []
    @eval_reaction.replies.each do |reply|
      repetition = reply.weight.nil? ? 1 : reply.weight
      repetition .times do
        reply.reaction_texts.each do |reaction_text|
          text = reaction_text.clone
          unless reply.prefix.nil?
            Random.rand(0..RANDOM_MAX).times { text.insert(0, reply.prefix) }
          end
          unless reply.suffix.nil?
            Random.rand(0..RANDOM_MAX).times { text << reply.suffix }
          end
          random_text_arr << text
        end
      end
    end
    Array(random_text_arr).sample
  end

  ###
  # 条件式
  ###

  # ツイートかどうか
  def tweet?
    @eval_entity.is_a?(Twitter::Tweet)
  end

  # イベントかどうか
  def event?
    @eval_entity.is_a?(Twitter::Streaming::Event)
  end

  # リプライかどうか
  def reply?
    @eval_entity.in_reply_to_user_id
  end

  # リツイートかどうか
  def retweet?
    @eval_entity.retweet?
  end

  # 自分宛のリプライかどうか
  def reply_to_me?
    @eval_entity.in_reply_to_user_id == @user.name ||
      @eval_entity.full_text.include?("@#{@user.screen_name}")
  end

  # 自分のツイートかどうか
  def mine?
    @eval_entity.user.id == @user.id
  end

  # イベントかどうか
  def fav?
    @eval_entity.name == :favorite
  end

  # 自分のツイートのお気に入りかどうか
  def fav_me?
    @eval_entity.user == @user.id
  end

  # ツイートの削除イベントかどうか
  def delete?
    @eval_entity.is_a?(Twitter::Streaming::DeletedTweet)
  end

  # ツイートのテキストに条件テキストが含まれるかチェック
  def text_in_tweet?
    text_arr = @eval_setting.condition.condition_texts
    return true if text_arr.empty? # 条件なし => true
    Array(text_arr).any? { |text| @eval_entity.full_text.include?(text) }
  end

  # リアクションを行うかの確率判定
  def hit?
    puts '確率判定なし！' unless @eval_setting.probability
    return true           unless @eval_setting.condition.probability
    (rand * 100).floor < @eval_setting.condition.probability
  end

  # 反応すべきユーザか判定
  def watching_user?
    return true if @eval_setting.condition.users.empty?
    @eval_setting.condition.users.include?(@eval_entity.users)
  end

  # 無視するユーザか判定
  # 無視する場合はtrue
  def ignore_user?
    return false if @eval_setting.condition.ng_users.empty?
    !@eval_setting.condition.ng_users.include?(@eval_entity.ng_users)
  end

  # 反応すべきクライアントかどうか判定
  def watching_client?
    return true if @eval_setting.condition.clients.empty?
    @eval_setting.condition.clients.include?(@eval_entity.clients)
  end

  # 会話になっているかどうかの判定
  def conversation?
    Twitter::Tweet.new(@eval_entity.in_reply_to_tweet_id).user == @user.id
  end
end
