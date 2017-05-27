#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
require WORK_DIR + 'Class/TetesolStreaming.rb'
rest_client   = TetesolTwitter.new(WORK_DIR + 'Config/unko.yml')
stream_client = TetesolStreaming.new(WORK_DIR + 'Config/stream.yml')
last_reply_id = "1"

#使用機能判定
args = ARGV
func_name = ""
func_name = "debug_mode" if args.delete("-d") or args.delete("-debug")
puts "#{func_name} mode"

#最後に反応したtweet_idを取得
last_reply_id = rest_client.read_or_make_text_file(WORK_DIR + "Config/.last_reply_id")

#反応する条件を読み込み
@condition = YAML.load_file('Config/reaction-condition.yml')
pp @condition

exit

#mention取得
monitored_tl = rest_client.mentions_timeline_bot(last_reply_id)
monitored_tl.reverse.each do |tweet|
  @text = tweet.full_text
  if @text.match("うんこ") or @text.match("クソ") then
    @str=""
    #内容重複よけ　それでも被ったら流さないでいい
    rand(15).times{ @str += "…"}
    #なぜ人は排便時に水を流すのか
    rest_client.reply(tweet.id ,"ジャーッ" + @str).id unless func_name == "debug_mode"
    last_reply_id = tweet.id
    pp last_reply_id if func_name == "debug_mode"
  end
end
#最後のtweet_idを保存
rest_client.write_text_to_file(WORK_DIR + "Config/.last_reply_id", last_reply_id)
