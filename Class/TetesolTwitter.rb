#!/usr/bin/env ruby
require 'twitter'
require 'yaml'
require 'sanitize'
require 'pp'
class TetesolTwitter
  attr_accessor :client

  def initialize( key_file_path = "" )
    if not key_file_path.empty? then
      @key_hash = YAML.load_file( key_file_path )
      config = {
        consumer_key:        @key_hash['consumer_key'],
        consumer_secret:     @key_hash['consumer_secret'],
        access_token:        @key_hash['access_token'],
        access_token_secret: @key_hash['access_token_secret']
      }
      @client = Twitter::REST::Client.new(config)
    else
      puts 'cannot read file_path...'
      exit
    end
  end

  #ツイートする機能
  #text :ツイートの内容
  def tweet( text = '' )
    if text == '' then
      print 'input massage! : '
      text = STDIN.gets
    end
    msg = text
    puts msg
    client.update( msg )
  end

  #リプライ機能。リプライ対象のidを読み取って、@(userid) (text)の形でpostする
  #target_tweet_id :リプライを送るツイートのid
  #text            :ツイートの内容
  def reply ( target_tweet_id = 0, text = '' )
    #リプライ対象のユーザを取得
    begin
      target_user = client.status( target_tweet_id ).user
    rescue
      puts 'target_user was not found...'
      return
    end
    msg = "@#{target_user.screen_name} " + text
#    msg = text #replyに@いらなくなる日が来る
    puts msg
    client.update(msg,{:in_reply_to_status_id => target_tweet_id})
  end

  #ホームタイムラインを取得して生jsonのまま返す
  def home_timeline( last_tweet_id )
    client.home_timeline({:since_id => last_tweet_id})
  end

  def local_trends( locale_code = 0 )
    hash = client.local_trends ( locale_code )
  end

  def search( query = '', count = 15 )
    timeline = client.search(query, {:count => count} )
  end

  def popular_search( query = '', count = 15 )
    timeline = client.search(query, {:count => count, :result_type => "popular"} )
  end

  #自分のTL
  def my_timeline
    client.user_timeline( client.user.id, {})
  end

  #誰かのTL
  def user_timeline(user_id, options = {})
    client.user_timeline( user_id )
  end

  #mention
  def mentions_timeline 
    client.mentions_timeline
  end

  #mention
  def mentions_timeline_bot(last_id) 
    client.mentions_timeline( {:since_id => last_id} )
  end

  #tweet_idに対してのreaction
  def retweet(id)
    client.retweet(id)
  end

  def favorite(id)
    client.favorite(id)
  end
  def unfavorite(id)
    client.unfavorite(id)
  end
  def status(id) #発言の詳細をゲットする
    @target = client.status(id)
    tweet_print_console(@target)
    @reactions = @target.user_mentions
    if @reactions.empty? then
      puts "*** reply none ***"
      return
    end
    @reactions.each do |item|
pp item
pp item.class
p item
    end
    tweets_print_console(@reactions, 1)
    tweets_print_console(tweet.user_mentions, 1)
  end
  def destroy_status(id) #発言削除
    client.destroy_status(id)
  end
  #####
  # 関連メソッド
  #####
  #ツイートIDから時刻を計算して返す
  def tweet_id_to_time(tweet_id)
    case tweet_id
    when Integer
      Time.at(((tweet_id >> 22) + 1288834974657) / 1000.0)
    else
      nil
    end
  end
  #timelineのtweet_id以降のタイムラインをコンソールに表示して、最後のtweet_idを返す
  def tweets_print_console(timeline_arr, tweet_id)
    @tweet_id = tweet_id
    timeline_arr.reverse.each do |tweet|
      tweet_print_console(tweet)
      @tweet_id = tweet.id.to_s
    end
    return @tweet_id
  end
  def tweet_print_console(tweet_entity)
       #タイムラインを表示
      puts "	#{tweet_entity.user.name} /@#{tweet_entity.user.screen_name} /#{tweet_id_to_time(tweet_entity.id).strftime("%Y-%m-%d %H:%M:%S.%L %Z")} : ( #{tweet_entity.id.to_s} ) fv:#{tweet_entity.favorite_count} rt:#{tweet_entity.retweet_count} #{Sanitize.clean(tweet_entity.source)}\n #{tweet_entity.full_text}\n"
      return tweet_entity.id
  end

  #YAMLに吐き出す機能？
  def tweet_print_yaml(timeline_hash, export_file_path)
    timeline_hash.each do |tweet|
      #タイムラインを表示
      open(export_file_path,"a+") do |e|
        YAML.dump( timeline_hash, e )
      end
    end
  end

  #読み込んだファイルの最終行だけを返す
  def read_or_make_text_file(file_path)
    text = ""
    if File.exist? (file_path)
      File.open(file_path,"r") do |file|
        file.each do |line|
          text += "#{line.chomp}"
        end
      end
    else
      File.open(file_path,"w")
      File.print(text)
    end
    return text
  end

  #渡されたtextをファイルに書き込む
  def write_text_to_file(file_path, text)
    File.open(file_path,"r+") do |file|
      file.puts(text)
    end
  end
end
