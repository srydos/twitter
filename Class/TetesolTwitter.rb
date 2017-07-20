#!/usr/bin/env ruby
require 'twitter'
require 'yaml'
require 'uri'
class TetesolTwitter
  #初期化
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

  #ツイートする機能
  #@param text :ツイートの内容
  #@return tweetツイートした結果オブジェクト
  def tweet(text = '')
    msg = text
    tweet = @client.update(msg)
  end

  #リプライ機能。リプライ対象のidを読み取って、@(userid) (text)の形でpostする
  #@param target_tweet_id :リプライを送るツイートのid
  #@param text            :ツイートの内容
  #@return tweetツイートした結果オブジェクト
  def reply (target_tweet_id = 0, text = '')
    #リプライ対象のユーザを取得
    begin
      target_user = @client.status(target_tweet_id).user
    rescue
      puts 'target_user was not found...'
      return
    end
    msg = "@#{target_user.screen_name} #{text}"
#    msg = text #replyに@いらなくなる日が来る
    tweet = @client.update(msg,{:in_reply_to_status_id => target_tweet_id})
  end

  #ホームタイムラインを取得して生jsonのまま返す
  def home_timeline(last_tweet_id)
    json =  @client.home_timeline({:since_id => last_tweet_id})
  end

  def local_trends(locale_code = 0)
    hash = @client.local_trends (locale_code)
  end

  def search(query = '', count = 15)
    timeline = @client.search(query, {:count => count})
  end

  def popular_search(query = '', count = 15)
    timeline = @client.search(query, {:count => count, :result_type => "popular"})
  end

  #自分のTL
  def my_timeline
    timeline = @client.user_timeline( @client.user.id, {})
  end

  #誰かのTL
  def user_timeline(user_id, options = {})
    timeline = @client.user_timeline(user_id)
  end

  #mention
  def mentions_timeline
    timeline = @client.mentions_timeline
  end

  #mention
  def mentions_timeline_bot(last_id)
    timeline = @client.mentions_timeline({:since_id => last_id})
  end

  #tweet_idに対してのreaction
  def retweet(id)
    tweet = @client.retweet(id)
  end

  def favorite(id)
    tweet = @client.favorite(id)
  end

  def favorite(id)
    @client.favorite(id)
  end

  def unfavorite(id)
    tweet = @client.unfavorite(id)
  end

  def status(id) #発言の詳細をゲットする
    dig_reply_to id
  end

  def dig_reply_to(id) #再帰的にリプライチェーンをたどる
    target = @client.status(id)
    return tweet_print_console(target) if target.in_reply_to_status_id.nil?
    dig_reply_to target.in_reply_to_status_id
    tweet_print_console(target)
  end

  def delete(id) #発言削除
    tweet = @client.destroy_status(id)
  end

  #####
  # 関連メソッド
  #####
  #ツイートIDから時刻を計算して返す
  def tweet_id_to_time(tweet_id)
    time = Time.at(((tweet_id >> 22) + 1288834974657) / 1000.0) if tweet_id.is_a?(Integer)
  end

  #timelineのtweet_id以降のタイムラインをコンソールに表示して、最後のtweet_idを返す
  def tweets_print_console(timeline, tweet_id)
    id = tweet_id
    timeline.reverse.each do |tweet|
      id = tweet_print_console(tweet)
    end
    id.to_s
  end

  def tweet_print_console(tweet)
    #ツイートを表示し、そのIDを返す
anker_tag_regex = %r(</?a.*?>)
header = %W(
#{tweet.user.name}
/@#{tweet.user.screen_name}
/
#{tweet_id_to_time(tweet.id).strftime("%Y-%m-%d %H:%M:%S")}
\s
(\s#{tweet.id.to_s}\s)
#{"\sfv:#{tweet.favorite_count}" if 0 < tweet.favorite_count}
#{"\srt:#{tweet.retweet_count}"  if 0 < tweet.retweet_count}
\s#{tweet.source.gsub(anker_tag_regex, "")}
\n
https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}
).join
    if tweet.retweet?
      print "********"
      puts header
      contexts = tweet.full_text.partition(": ")
      if contexts[0].slice!(0, 4) == "RT @" #user.screen_name
        rt_user, _separator, rt_text = contexts
      end
      puts "  -->#{tweet.attrs[:retweeted_status][:user][:name] rescue nil}/@#{rt_user}/#{tweet_id_to_time(tweet.attrs[:retweeted_status][:id]).strftime("%Y-%m-%d %H:%M:%S")}( #{tweet.attrs[:retweeted_status][:id]} )"
      puts rt_text
    else
      print "\t"
      puts header
      puts "#{tweet.text}"
    end
    tweet.attrs[:entities][:urls].to_a.map {|u| puts "[#{URI.unescape(u[:expanded_url])}]"} if tweet.urls?
    tweet.attrs[:extended_entities][:media].to_a.map{|m| puts "<#{m[:media_url]}>"} if tweet.media?
    tweet.attrs
    puts nil #break line
    tweet.id.to_s
  end

  #YAMLに吐き出す機能？
  #TODO 命名も含めて見直す
  def tweet_print_yaml(timeline_hash, export_file_path)
    timeline_hash.each do |tweet|
      #タイムラインを表示
      open(export_file_path,"a+") do |e|
        YAML.dump(timeline_hash, e)
      end
    end
  end

  #読み込んだファイルの最終行だけを返す
  #なければ作成する
  def read_textfile_or_new(file_path)
    text = ""
    if File.exist? (file_path)
      File.open(file_path,"r") do |file|
        file.each do |line|
          text += "#{line.chomp}"
        end
      end
    else
      File.open(file_path,"w") do |file|
        file.puts(text)
      end
    end
    text
  end

  #渡されたtextをファイルに書き込む
  def write_text_to_file(file_path, text)
    File.open(file_path,"r+") do |file|
      file.puts(text)
    end
  end
end
