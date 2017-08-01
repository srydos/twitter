# frozen_string_literal: true

require 'twitter'
require 'yaml'
require 'uri'

# ててそるで使うついった機能まとめ
class TetesolTwitter
  # 初期化
  attr_accessor :user
  def initialize(key_file_path)
    key_hash = YAML.load_file(key_file_path)
    config = {
      consumer_key:        key_hash[:consumer_key],
      consumer_secret:     key_hash[:consumer_secret],
      access_token:        key_hash[:access_token],
      access_token_secret: key_hash[:access_token_secret]
    }
    @client = Twitter::REST::Client.new(config)
    @user   = @client.user
  end

  # ツイートする機能
  # @param text :ツイートの内容
  # @return tweetツイートした結果オブジェクト
  def tweet(text = '')
    msg = text
    _tweet = @client.update(msg)
  end

  # リプライ機能。リプライ対象のidを読み取って、@(userid) (text)の形でpostする
  # @param target_tweet_id :リプライを送るツイートのid
  # @param text            :ツイートの内容
  # @return tweetツイートした結果オブジェクト
  def reply(target_tweet_id = 0, text = '')
    # リプライ対象のユーザを取得
    begin
      target_user = @client.status(target_tweet_id).user
    rescue
      puts 'target_user was not found...'
      return
    end
    msg = "@#{target_user.screen_name} #{text}"
    # msg = text #replyに@いらなくなる日が来る
    _tweet = @client.update(msg, in_reply_to_status_id: target_tweet_id)
  end

  # ホームタイムラインを取得して生jsonのまま返す
  def home_timeline(last_tweet_id)
    _json = @client.home_timeline(since_id: last_tweet_id)
  end

  def local_trends(locale_code = 0)
    _hash = @client.local_trends(locale_code)
  end

  def search(query = '', count = 15)
    _timeline = @client.search(query, count: count)
  end

  def popular_search(query = '', count = 15)
    _timeline = @client.search(query, count: count, result_type: 'popular')
  end

  # 自分のTL
  def my_timeline
    _timeline = @client.user_timeline(@client.user.id, {})
  end

  # 誰かのTL
  def user_timeline(user_id, options = {})
    _timeline = @client.user_timeline(user_id, options)
  end

  # mention
  def mentions_timeline
    _timeline = @client.mentions_timeline
  end

  # mention
  def mentions_timeline_bot(last_id)
    _timeline = @client.mentions_timeline(since_id: last_id)
  end

  # tweet_idに対してのreaction
  def retweet(id)
    _tweet = @client.retweet(id)
  end

  def favorite(id)
    _tweet = @client.favorite(id)
  end

  def unfavorite(id)
    _tweet = @client.unfavorite(id)
  end

  def status(id) # 発言の詳細をゲットする
    dig_reply_to id
  end

  def dig_reply_to(id) # 再帰的にリプライチェーンをたどる
    target = @client.status(id)
    return tweet_print_console(target) if target.in_reply_to_status_id.nil?
    dig_reply_to target.in_reply_to_status_id
    tweet_print_console(target)
  end

  def delete(id) # 発言削除
    _tweet = @client.destroy_status(id)
  end

  #####
  # 関連メソッド
  #####
  # ツイートIDから時刻を計算して返す
  def tweet_id_to_time(tweet_id)
    Time.at(((tweet_id >> 22) + 1_288_834_974_657) / 1000.0)
        .strftime('%Y-%m-%d %H:%M:%S')
  end

  # timelineのtweet_id以降のタイムラインをコンソールに表示して、最後のtweet_idを返す
  def tweets_print_console(timeline, tweet_id)
    id = tweet_id
    timeline.reverse.each do |tweet|
      id = tweet_print_console(tweet)
    end
    id.to_s
  end

  # ツイートを表示し、そのIDを返す
  def tweet_print_console(tweet)
    header = make_print_header(tweet)
    if tweet.retweet?
      puts "********#{header}\n#{make_print_retweet(tweet)}"
    else
      puts "\t#{header}\n#{tweet.text}"
    end
    if tweet.urls?
      tweet.attrs[:entities][:urls].to_a.map do |u|
        puts "[ #{URI.unescape(u[:expanded_url])} ]"
      end
    end
    if tweet.media?
      tweet.attrs[:extended_entities][:media].to_a.map do |m|
        puts "< #{m[:media_url]} >"
      end
    end
    puts nil # break line
    tweet.id.to_s
  end

  def make_print_header(tweet)
    anker_tag_regex = %r{</?a.*?>}
    id = tweet.id
    user = tweet.user
    name = user.screen_name
    favs = tweet.favorite_count
    rts = tweet.retweet_count
    %W[
      #{user.name}
      \s/@#{name}
      \s/#{tweet_id_to_time(id)}
      \s (\s#{tweet.id}\s)
      #{"\sfv:#{favs}" if favs.positive?}
      #{"\srt:#{rts}" if rts.positive?}
      \s#{tweet.source.gsub(anker_tag_regex, '')}
      \n
      https://twitter.com/#{name}/status/#{id}
    ].join
  end

  def make_print_retweet(tweet)
    rt_user, _separator, rt_text = tweet.full_text.slice(4..-1).partition(': ')
    rt_status = tweet.attrs[:retweeted_status]
    %W[
      \s
      \s-->#{rt_status[:user][:name]}
      /\s@#{rt_user}
      /\s#{tweet_id_to_time(rt_status[:id])}
      (\s#{rt_status[:id]}\s)
      \n#{rt_text}
    ].join
  end

  # YAMLに吐き出す機能
  def tweet_to_yaml(timeline_hash, export_file_path)
    timeline_hash.each do
      # タイムラインを表示
      open(export_file_path, 'a+') do |e|
        YAML.dump(timeline_hash, e)
      end
    end
  end

  # 読み込んだファイルの最終行だけを返す
  # なければ作成する
  def read_textfile_or_new(file_path)
    if File.exist?(file_path)
      File.read(file_path)
    else
      File.write(file_path, '1')
    end
  end

  # 渡されたtextをファイルに書き込む
  def write_text_to_file(file_path, text)
    File.write(file_path, text)
  end
end
