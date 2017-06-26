#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
require WORK_DIR + 'Class/TetesolStreaming.rb'
require WORK_DIR + './Class/TetesolBot.rb'
rest_client   = TetesolTwitter.new(WORK_DIR + 'Config/unko.yml')
stream_client = TetesolStreaming.new(WORK_DIR + 'Config/stream.yml')
last_reply_id = "1"

#使用機能判定
args = ARGV
func_name = ""
func_name = "debug_mode" if args.delete("-d") or args.delete("-debug")
#puts "func#{func_name}"

#最後に反応したtweet_idを取得
last_reply_id = rest_client.read_or_make_text_file(WORK_DIR + "Config/.last_reply_id")
last_reply_id ="1" if last_reply_id.empty?
last = last_reply_id.to_i

#botクラス読み込み
conver_bot = TetesolBot.new(WORK_DIR + "Config/user.yml", WORK_DIR + "Config/reaction-condition.yml")

#replyから反応
replied_id = 1
monitored_tl = rest_client.mentions_timeline_bot(last_reply_id)
monitored_tl.reverse.each do |tweet|
  replied_id = conver_bot.reaction_tweet(tweet) if !tweet.retweet?
  last = (replied_id < last)? last : replied_id
end

#最後のtweet_idを保存
last_reply_id = last.to_s
puts "seen_id : #{last_reply_id}"
rest_client.write_text_to_file(WORK_DIR + "Config/.last_reply_id", last_reply_id)
